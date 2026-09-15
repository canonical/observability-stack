"""Steps about telemetry reaching its backend: metrics, logs and traces.

All three signals are checked the same way -- every component's telemetry
carries a `juju_application` label (or, for traces, resource attribute), so
finding it proves the data came from that specific application. Unlike checking
`up`, this also holds for remote-written metrics, where there is no scrape
target to look at, and it does not care whether the component delivered the
telemetry itself or a collector did it on its behalf.

One step definition per backend (Prometheus, Mimir, ...) rather than one
parameterized over the backend name: each asks for its own client fixture, so a
solution only ever builds clients for the components it actually deploys.
"""

import time
from collections.abc import Callable
from contextlib import suppress

from observability_clients import Loki, Mimir, Prometheus, Tempo
from pytest_bdd import parsers, then
from tenacity import RetryError, Retrying, retry_if_result, stop_after_delay, wait_fixed

# How far back to look for logs and traces. Components like Alertmanager and
# Mimir are quiet once running, so their only log lines may date to deployment
# time; charm traces are likewise only emitted while hooks are running.
_LOOKBACK_HOURS = 24


def _eventually(check: Callable[..., bool], **kwargs) -> bool:
    """Poll `check` until it returns True, giving up after a couple of minutes.

    Ingestion is periodic, so the first samples for an application can land a
    little after the model has settled into active/idle.
    """
    retrying = Retrying(
        retry=retry_if_result(lambda result: result is False),
        wait=wait_fixed(10),
        stop=stop_after_delay(60 * 2),
    )
    with suppress(RetryError):
        return retrying(check, **kwargs)
    return False


def _lookback_window_ns() -> tuple[int, int]:
    end = time.time_ns()
    return end - _LOOKBACK_HOURS * 3600 * 1_000_000_000, end


@then(parsers.parse('Prometheus has metrics from the "{application}" application'))
def prometheus_has_metrics_from(prometheus: Prometheus, application: str):
    labels = {"juju_application": application}
    assert _eventually(prometheus.has_metric, labels=labels), (
        f"Prometheus has no metrics labelled juju_application={application}"
    )


@then(parsers.parse('Mimir has metrics from the "{application}" application'))
def mimir_has_metrics_from(mimir: Mimir, application: str):
    """Metrics reach Mimir by remote write rather than by Mimir scraping them,
    so they can trail the model settling by a full collector export interval.
    """
    labels = {"juju_application": application}
    assert _eventually(mimir.has_metric, labels=labels), (
        f"Mimir has no metrics labelled juju_application={application}"
    )


@then(parsers.parse('Loki has logs from the "{application}" application'))
def loki_has_logs_from(loki: Loki, application: str):
    """Uses a range query over a wide window, rather than `has_log_line`.

    Loki rejects log selectors on the instant-query endpoint that
    `has_log_line` uses, and quiet components only log around startup, which a
    short lookback would miss.
    """
    start, end = _lookback_window_ns()
    result = loki.query_range(
        f'{{juju_application="{application}"}}', start=str(start), end=str(end), limit=1
    )
    assert result.get("data", {}).get("result"), (
        f"Loki has no log streams labelled juju_application={application} "
        f"in the last {_LOOKBACK_HOURS}h"
    )


@then(parsers.parse('Tempo has traces from the "{application}" application'))
def tempo_has_traces_from(tempo: Tempo, application: str):
    """Searched over a wide window: charm traces are only emitted while a hook
    runs, so a settled model may not have produced a span in a while.
    """
    start, end = _lookback_window_ns()

    def has_traces() -> bool:
        result = tempo.search(
            f'{{resource.juju_application="{application}"}}',
            start=str(start // 1_000_000_000),
            end=str(end // 1_000_000_000),
            limit=1,
        )
        return bool(result.get("traces"))

    assert _eventually(has_traces), (
        f"Tempo has no traces with resource.juju_application={application} "
        f"in the last {_LOOKBACK_HOURS}h"
    )

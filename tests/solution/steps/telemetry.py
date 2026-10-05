"""Steps about telemetry reaching its backend."""

from observability_clients import Loki, Mimir, Prometheus, Tempo
from pytest_bdd import parsers, then
from tenacity import RetryError, Retrying, retry_if_result, stop_after_delay, wait_fixed

from helpers import LOOKBACK_HOURS, lookback_window_ns


@then(parsers.parse('Prometheus has metrics from the "{application}" application'))
def prometheus_has_metrics_from(prometheus: Prometheus, application: str):
    """Assert whether Prometheus has metrics with a given `juju_application` label."""
    found = False
    retrying = Retrying(
        retry=retry_if_result(lambda result: result is False),
        wait=wait_fixed(10),
        # Scraping is periodic, so the first samples for an application can
        # land a little after the model has settled into active/idle.
        stop=stop_after_delay(60 * 2),
    )
    try:
        found = retrying(
            prometheus.has_metric, labels={"juju_application": application}
        )
    except RetryError:
        pass
    assert found, f"Prometheus has no metrics labelled juju_application={application}"


@then(parsers.parse('Mimir has metrics from the "{application}" application'))
def mimir_has_metrics_from(mimir: Mimir, application: str):
    """Assert whether Mimir has metrics with a given `juju_application` label."""
    assert mimir.has_metric(labels={"juju_application": application}), (
        f"Mimir has no metrics labelled juju_application={application}"
    )


@then(parsers.parse('Loki has logs from the "{application}" application'))
def loki_has_logs_from(loki: Loki, application: str):
    """Assert Loki has logs with a given `juju_application` label."""
    start, end = lookback_window_ns()
    result = loki.query_range(
        f'{{juju_application="{application}"}}', start=str(start), end=str(end), limit=1
    )
    assert result.get("data", {}).get("result"), (
        f"Loki has no log lines labelled juju_application={application} "
        f"in the last {LOOKBACK_HOURS}h"
    )


@then(parsers.parse('Tempo has traces from the "{application}" application'))
def tempo_has_traces_from(tempo: Tempo, application: str):
    """Assert Tempo has traces with a given `resource.juju_application` attribute."""
    start, end = lookback_window_ns()
    result = tempo.search(
        f'{{resource.juju_application="{application}"}}',
        start=str(start // 1_000_000_000),
        end=str(end // 1_000_000_000),
        limit=1,
    )
    assert result.get("traces"), (
        f"Tempo has no traces with resource.juju_application={application} "
        f"in the last {LOOKBACK_HOURS}h"
    )

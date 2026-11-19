"""Steps about telemetry reaching its backend."""

from observability_clients import Loki, Mimir, Prometheus, Tempo
from pytest_bdd import parsers, then
from tenacity import retry, stop_after_delay, wait_fixed

from helpers import LOOKBACK_HOURS, lookback_window_ns

# Scraping and ingestion are periodic, so the first data of an application can land a little
# after the model has settled into active/idle. A retry runs its step again, so it also looks
# at a lookback window that has moved on.
_until_ingested = retry(
    wait=wait_fixed(10), stop=stop_after_delay(60 * 2), reraise=True
)


@then(parsers.parse('Prometheus has metrics from the "{application}" application'))
@_until_ingested
def prometheus_has_metrics_from(prometheus: Prometheus, application: str):
    assert prometheus.has_metric(labels={"juju_application": application}), (
        f"Prometheus has no metrics labelled juju_application={application}"
    )


@then(parsers.parse('Mimir has metrics from the "{application}" application'))
@_until_ingested
def mimir_has_metrics_from(mimir: Mimir, application: str):
    assert mimir.has_metric(labels={"juju_application": application}), (
        f"Mimir has no metrics labelled juju_application={application}"
    )


@then(parsers.parse('Loki has logs from the "{application}" application'))
@_until_ingested
def loki_has_logs_from(loki: Loki, application: str):
    start, end = lookback_window_ns()
    result = loki.query_range(
        f'{{juju_application="{application}"}}', start=str(start), end=str(end), limit=1
    )
    assert result.get("data", {}).get("result"), (
        f"Loki has no log lines labelled juju_application={application} "
        f"in the last {LOOKBACK_HOURS}h"
    )


@then(parsers.parse('Tempo has traces from the "{application}" application'))
@_until_ingested
def tempo_has_traces_from(tempo: Tempo, application: str):
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

"""Steps about telemetry reaching its backend."""

import time

from observability_clients import Loki, Prometheus
from pytest_bdd import parsers, then
from tenacity import RetryError, Retrying, retry_if_result, stop_after_delay, wait_fixed

# How far back to look for logs. Components like Alertmanager and Prometheus are
# quiet once running, so their only log lines may date to deployment time.
_LOG_LOOKBACK_HOURS = 24


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


@then(parsers.parse('Loki has logs from the "{application}" application'))
def loki_has_logs_from(loki: Loki, application: str):
    """Assert Loki has logs with a given `juju_application` label."""
    end = time.time_ns()
    start = end - _LOG_LOOKBACK_HOURS * 3600 * 1_000_000_000
    result = loki.query_range(
        f'{{juju_application="{application}"}}', start=str(start), end=str(end), limit=1
    )
    assert result.get("data", {}).get("result"), (
        f"Loki has no log lines labelled juju_application={application} "
        f"in the last {_LOG_LOOKBACK_HOURS}h"
    )

"""Steps about telemetry reaching its backend: metrics and logs.

Both signals are checked the same way -- every component's telemetry carries a
`juju_application` label, so finding that label proves the data came from that
specific application. Unlike checking `up`, this also holds for remote-written
metrics, where there is no scrape target to look at.

One step definition per backend (Prometheus, Mimir, ...) rather than one
parameterized over the backend name: each asks for its own client fixture, so a
solution only ever builds clients for the components it actually deploys.
"""

from contextlib import suppress

from observability_clients import Loki, Prometheus
from pytest_bdd import parsers, then
from tenacity import RetryError, Retrying, retry_if_result, stop_after_delay, wait_fixed


@then(parsers.parse('Prometheus has metrics from the "{application}" application'))
def prometheus_has_metrics_from(prometheus: Prometheus, application: str):
    """Retried: scraping is periodic, so the first samples for an application can
    land a little after the model has settled into active/idle.
    """
    found = False
    retrying = Retrying(
        retry=retry_if_result(lambda result: result is False),
        wait=wait_fixed(10),
        stop=stop_after_delay(60 * 2),
    )
    with suppress(RetryError):
        found = retrying(prometheus.has_metric, labels={"juju_application": application})
    assert found, f"Prometheus has no metrics labelled juju_application={application}"


@then(parsers.parse('Loki has logs from the "{application}" application'))
def loki_has_logs_from(loki: Loki, application: str):
    assert loki.has_log_line(f'{{juju_application="{application}"}}'), (
        f"Loki has no log streams labelled juju_application={application}"
    )

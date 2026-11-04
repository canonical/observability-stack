"""Steps about telemetry reaching its backend."""

import jubilant
from observability_clients import Loki, Mimir, Prometheus, Tempo
from pytest_bdd import parsers, then

from helpers import (
    LOOKBACK_HOURS,
    _expect_deployed,
    loki_has_logs,
    retry_until_found,
    tempo_has_traces,
)


@then(parsers.parse('Prometheus has metrics from the "{application}" application'))
def prometheus_has_metrics_from(
    prometheus: Prometheus, juju: jubilant.Juju, request, application: str
):
    """Assert whether Prometheus has metrics with a given `juju_application` label."""
    _expect_deployed(juju, request, application)
    found = retry_until_found(
        lambda: prometheus.has_metric(labels={"juju_application": application})
    )
    assert found, f"Prometheus has no metrics labelled juju_application={application}"


@then(parsers.parse('Mimir has metrics from the "{application}" application'))
def mimir_has_metrics_from(
    mimir: Mimir, juju: jubilant.Juju, request, application: str
):
    """Assert whether Mimir has metrics with a given `juju_application` label."""
    _expect_deployed(juju, request, application)
    found = retry_until_found(
        lambda: mimir.has_metric(labels={"juju_application": application})
    )
    assert found, f"Mimir has no metrics labelled juju_application={application}"


@then(parsers.parse('Loki has logs from the "{application}" application'))
def loki_has_logs_from(loki: Loki, juju: jubilant.Juju, request, application: str):
    """Assert Loki has logs with a given `juju_application` label."""
    _expect_deployed(juju, request, application)
    assert retry_until_found(lambda: loki_has_logs(loki, application)), (
        f"Loki has no log lines labelled juju_application={application} "
        f"in the last {LOOKBACK_HOURS}h"
    )


@then(parsers.parse('Tempo has traces from the "{application}" application'))
def tempo_has_traces_from(
    tempo: Tempo, juju: jubilant.Juju, request, application: str
):
    """Assert Tempo has traces with a given `resource.juju_application` attribute."""
    _expect_deployed(juju, request, application)
    assert retry_until_found(lambda: tempo_has_traces(tempo, application)), (
        f"Tempo has no traces with resource.juju_application={application} "
        f"in the last {LOOKBACK_HOURS}h"
    )

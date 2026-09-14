"""Steps about Grafana as a domain: the dashboards and datasources it aggregates."""

from observability_clients import Grafana
from pytest_bdd import parsers, then


@then(parsers.parse('Grafana has a dashboard from the "{charm}" charm'))
def grafana_has_a_dashboard_from(grafana: Grafana, charm: str):
    """Dashboards are matched on their `charm:` tag, which is stabler than titles."""
    assert grafana.has_dashboard_with_tag(f"charm: {charm}"), (
        f"Grafana has no dashboard tagged 'charm: {charm}'"
    )


@then(
    parsers.parse('Grafana has a datasource for the "{application}" application'),
    target_fixture="datasource",
)
def grafana_has_a_datasource_for(grafana: Grafana, application: str) -> dict:
    """Grafana names charm-provided datasources `juju_<model>_<uuid>_<app>_<unit>`."""
    for datasource in grafana.get_datasources():
        parts = datasource.get("name", "").split("_")
        if len(parts) >= 2 and parts[-2] == application:
            return datasource
    raise AssertionError(f"Grafana has no datasource for '{application}'")


@then("that datasource is healthy")
def that_datasource_is_healthy(grafana: Grafana, datasource: dict):
    assert grafana.is_datasource_healthy(uid=datasource["uid"]), (
        f"Grafana datasource '{datasource['name']}' is not healthy"
    )

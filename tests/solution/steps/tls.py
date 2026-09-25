"""Steps about internal TLS: which scheme a component is actually reachable over."""

from urllib.parse import urlparse

import jubilant
from helpers import unit_url
from pytest_bdd import parsers, then

# Mirrors the ports clients.py's fixtures use.
_PORTS = {
    "alertmanager": 9093,
    "grafana": 3000,
    "loki": 3100,
    "mimir": 8080,
    "prometheus": 9090,
    "tempo": 3200,
}


@then(parsers.parse('the "{application}" application is served over "{scheme}"'))
def application_is_served_over(juju: jubilant.Juju, application: str, scheme: str):
    url = unit_url(juju, application, _PORTS[application])
    actual = urlparse(url).scheme
    assert actual == scheme, f"{application} is served over {actual}, expected {scheme}"

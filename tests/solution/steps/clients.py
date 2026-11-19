"""Fixtures giving the steps an API client for each workload the solution deploys."""

import base64
import json
from typing import Any, Dict

import jubilant
import pytest
from observability_clients import Alertmanager, Grafana, Loki, Mimir, Prometheus, Tempo

from helpers import app_url, leader_unit


@pytest.fixture(scope="module")
def proxied_endpoints(juju: jubilant.Juju) -> Dict[str, Any]:
    """Traefik's ingress routes, keyed by application; empty when there is no Traefik."""
    if "traefik" not in juju.status().apps:
        return {}
    task = juju.run(leader_unit(juju, "traefik"), "show-proxied-endpoints")
    return json.loads(task.results["proxied-endpoints"])


@pytest.fixture(scope="module")
def grafana_admin_credentials(juju: jubilant.Juju) -> str:
    """Basic-auth header value for Grafana's admin user, with the charm-generated password."""
    password = juju.run(leader_unit(juju, "grafana"), "get-admin-password").results[
        "admin-password"
    ]
    return base64.b64encode(f"admin:{password}".encode()).decode()


@pytest.fixture
def alertmanager(
    juju: jubilant.Juju, proxied_endpoints: Dict[str, Any]
) -> Alertmanager:
    return Alertmanager(url=app_url(juju, proxied_endpoints, "alertmanager"))


@pytest.fixture
def grafana(
    juju: jubilant.Juju,
    proxied_endpoints: Dict[str, Any],
    grafana_admin_credentials: str,
) -> Grafana:
    return Grafana(
        url=app_url(juju, proxied_endpoints, "grafana"),
        headers={"Authorization": f"Basic {grafana_admin_credentials}"},
    )


@pytest.fixture
def loki(juju: jubilant.Juju, proxied_endpoints: Dict[str, Any]) -> Loki:
    return Loki(url=app_url(juju, proxied_endpoints, "loki"))


@pytest.fixture
def mimir(juju: jubilant.Juju, proxied_endpoints: Dict[str, Any]) -> Mimir:
    return Mimir(url=app_url(juju, proxied_endpoints, "mimir"))


@pytest.fixture
def prometheus(juju: jubilant.Juju, proxied_endpoints: Dict[str, Any]) -> Prometheus:
    return Prometheus(url=app_url(juju, proxied_endpoints, "prometheus"))


@pytest.fixture
def tempo(juju: jubilant.Juju, proxied_endpoints: Dict[str, Any]) -> Tempo:
    return Tempo(url=app_url(juju, proxied_endpoints, "tempo"))

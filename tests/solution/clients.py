# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""API client fixtures for the workloads involved in the solution tests."""

import base64
import functools

import jubilant
import pytest
from observability_clients import Alertmanager, Grafana, Loki, Mimir, Prometheus, Tempo

from helpers import leader_unit, unit_url

_PORTS = {
    "alertmanager": 9093,
    "grafana": 3000,
    "loki": 3100,
    "mimir": 8080,
    "prometheus": 9090,
    "tempo": 3200,
}


@pytest.fixture
def alertmanager(juju: jubilant.Juju) -> Alertmanager:
    return Alertmanager(url=unit_url(juju, "alertmanager", _PORTS["alertmanager"]))


@functools.cache
def _grafana_admin_credentials(model: str) -> str:
    """Basic-auth header value for Grafana's admin user, cached per model.

    This avoids re-running the action for every scenario.
    """
    juju = jubilant.Juju(model=model)
    password = juju.run(leader_unit(juju, "grafana"), "get-admin-password").results[
        "admin-password"
    ]
    return base64.b64encode(f"admin:{password}".encode()).decode()


@pytest.fixture
def grafana(juju: jubilant.Juju) -> Grafana:
    """Grafana, authenticated as admin with the charm-generated password."""
    credentials = _grafana_admin_credentials(juju.model)
    return Grafana(
        url=unit_url(juju, "grafana", _PORTS["grafana"]),
        headers={"Authorization": f"Basic {credentials}"},
    )


@pytest.fixture
def loki(juju: jubilant.Juju) -> Loki:
    return Loki(url=unit_url(juju, "loki", _PORTS["loki"]))


@pytest.fixture
def mimir(juju: jubilant.Juju) -> Mimir:
    return Mimir(url=unit_url(juju, "mimir", _PORTS["mimir"]))


@pytest.fixture
def prometheus(juju: jubilant.Juju) -> Prometheus:
    return Prometheus(url=unit_url(juju, "prometheus", _PORTS["prometheus"]))


@pytest.fixture
def tempo(juju: jubilant.Juju) -> Tempo:
    return Tempo(url=unit_url(juju, "tempo", _PORTS["tempo"]))

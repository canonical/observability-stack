# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""API client fixtures for the workloads involved in the solution tests."""

import base64
import functools

import jubilant
import pytest
from observability_clients import Alertmanager, Grafana, Loki, Mimir, Prometheus, Tempo

from helpers import _PORTS, ingressed_url, leader_unit, unit_url


@pytest.fixture
def alertmanager(juju: jubilant.Juju, request) -> Alertmanager:
    port = _PORTS["alertmanager"]
    url = ingressed_url(juju, request, "alertmanager", port) or unit_url(
        juju, "alertmanager", port
    )
    return Alertmanager(url=url)


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
def grafana(juju: jubilant.Juju, request) -> Grafana:
    """Grafana, authenticated as admin with the charm-generated password."""
    credentials = _grafana_admin_credentials(juju.model)
    port = _PORTS["grafana"]
    url = ingressed_url(juju, request, "grafana", port) or unit_url(
        juju, "grafana", port
    )
    return Grafana(
        url=url,
        headers={"Authorization": f"Basic {credentials}"},
    )


@pytest.fixture
def loki(juju: jubilant.Juju, request) -> Loki:
    port = _PORTS["loki"]
    url = ingressed_url(juju, request, "loki", port) or unit_url(juju, "loki", port)
    return Loki(url=url)


@pytest.fixture
def mimir(juju: jubilant.Juju, request) -> Mimir:
    port = _PORTS["mimir"]
    url = ingressed_url(juju, request, "mimir", port) or unit_url(juju, "mimir", port)
    return Mimir(url=url)


@pytest.fixture
def prometheus(juju: jubilant.Juju, request) -> Prometheus:
    port = _PORTS["prometheus"]
    url = ingressed_url(juju, request, "prometheus", port) or unit_url(
        juju, "prometheus", port
    )
    return Prometheus(url=url)


@pytest.fixture
def tempo(juju: jubilant.Juju, request) -> Tempo:
    port = _PORTS["tempo"]
    url = ingressed_url(juju, request, "tempo", port) or unit_url(juju, "tempo", port)
    return Tempo(url=url)

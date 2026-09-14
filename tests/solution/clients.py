# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""API client fixtures, one per workload the solution tests talk to.

Steps ask for the component they need by name (`prometheus`, `loki`, ...) and
get an `observability-clients` client pointed at that application in the model.

Each fixture is only built when a step actually requests it, so a fixture for a
component a given solution doesn't deploy is simply never evaluated -- COS Lite
scenarios can use `prometheus` while COS scenarios use `mimir`, from the same
shared file.
"""

import base64

import jubilant
import pytest
from helpers import unit_url
from observability_clients import Alertmanager, Grafana, Loki, Mimir, Prometheus, Tempo


@pytest.fixture
def alertmanager(juju: jubilant.Juju) -> Alertmanager:
    return Alertmanager(url=unit_url(juju, "alertmanager", 9093))


@pytest.fixture
def grafana(juju: jubilant.Juju) -> Grafana:
    """Grafana, authenticated as admin with the charm-generated password."""
    password = juju.run("grafana/0", "get-admin-password").results["admin-password"]
    credentials = base64.b64encode(f"admin:{password}".encode()).decode()
    return Grafana(
        url=unit_url(juju, "grafana", 3000),
        headers={"Authorization": f"Basic {credentials}"},
    )


@pytest.fixture
def loki(juju: jubilant.Juju) -> Loki:
    return Loki(url=unit_url(juju, "loki", 3100))


@pytest.fixture
def mimir(juju: jubilant.Juju) -> Mimir:
    return Mimir(url=unit_url(juju, "mimir", 8080))


@pytest.fixture
def prometheus(juju: jubilant.Juju) -> Prometheus:
    return Prometheus(url=unit_url(juju, "prometheus", 9090))


@pytest.fixture
def tempo(juju: jubilant.Juju) -> Tempo:
    return Tempo(url=unit_url(juju, "tempo", 3200))

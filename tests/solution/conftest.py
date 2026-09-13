#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: tag filtering, step registration and fixtures.

Step definitions live under steps/ (one module per feature, plus
common_steps.py for steps shared across features), registered below via
pytest_plugins so every solution shares them (see README.md).
"""

import base64
from pathlib import Path
from typing import Iterator

import jubilant
import pytest
from helpers import app_absent, discover_solutions, eventually, resolve_model_name, wait_for_active_idle
from observability_clients import Alertmanager, Grafana, Loki, Prometheus

pytest_plugins = [
    "steps.common_steps",
    "steps.self_monitoring_steps",
    "steps.alert_steps",
    "steps.grafana_steps",
]

_SOLUTIONS = discover_solutions()

PORTS = {"prometheus": 9090, "loki": 3100, "alertmanager": 9093, "grafana": 3000}

AVALANCHE_APP = "avalanche"
AVALANCHE_CHANNEL = "2/stable"
REMOVE_TIMEOUT = 300


def pytest_configure(config: pytest.Config) -> None:
    for solution in _SOLUTIONS:
        config.addinivalue_line("markers", f"{solution}: scenario only applies to the '{solution}' solution")


def pytest_collection_modifyitems(config: pytest.Config, items: list[pytest.Item]) -> None:
    """Deselect scenarios tagged for a solution other than the one being tested.

    Every solution loads every feature file (see each test_solution.py); an
    untagged scenario runs for all of them, one tagged e.g. `@cos-lite` runs
    only under tests/solution/cos-lite/.
    """
    kept, deselected = [], []
    for item in items:
        solution = item.path.parent.name
        tags = {mark.name for mark in item.iter_markers()} & _SOLUTIONS
        (deselected if tags and solution not in tags else kept).append(item)
    if deselected:
        config.hook.pytest_deselected(items=deselected)
        items[:] = kept


def _url(juju: jubilant.Juju, app: str) -> str:
    return f"http://{juju.status().apps[app].address}:{PORTS[app]}"


@pytest.fixture(scope="module")
def juju(request: pytest.FixtureRequest) -> jubilant.Juju:
    return jubilant.Juju(model=resolve_model_name(Path(request.module.__file__).parent))


@pytest.fixture(scope="module")
def cos_model(juju: jubilant.Juju) -> jubilant.Juju:
    """The solution's model, settled to active/idle."""
    wait_for_active_idle(juju)
    return juju


@pytest.fixture(scope="module")
def prometheus(cos_model: jubilant.Juju) -> Prometheus:
    return Prometheus(url=_url(cos_model, "prometheus"))


@pytest.fixture(scope="module")
def loki(cos_model: jubilant.Juju) -> Loki:
    return Loki(url=_url(cos_model, "loki"))


@pytest.fixture(scope="module")
def alertmanager(cos_model: jubilant.Juju) -> Alertmanager:
    return Alertmanager(url=_url(cos_model, "alertmanager"))


@pytest.fixture(scope="module")
def grafana(cos_model: jubilant.Juju) -> Grafana:
    password = cos_model.run("grafana/leader", "get-admin-password").results["admin-password"]
    token = base64.b64encode(f"admin:{password}".encode()).decode()
    return Grafana(url=_url(cos_model, "grafana"), headers={"Authorization": f"Basic {token}"})


@pytest.fixture(scope="module")
def avalanche(cos_model: jubilant.Juju) -> Iterator[None]:
    """Avalanche deployed and integrated with Prometheus, removed on teardown."""
    cos_model.deploy("avalanche-k8s", AVALANCHE_APP, channel=AVALANCHE_CHANNEL)
    cos_model.integrate(f"{AVALANCHE_APP}:metrics-endpoint", "prometheus:metrics-endpoint")
    wait_for_active_idle(cos_model)
    yield
    cos_model.remove_application(AVALANCHE_APP, destroy_storage=True, force=True)
    assert eventually(app_absent, cos_model, AVALANCHE_APP, timeout=REMOVE_TIMEOUT), (
        f"{AVALANCHE_APP} was not removed from {cos_model.model}"
    )


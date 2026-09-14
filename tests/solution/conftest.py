#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: tag filtering + step registration.

Step definitions live under steps/, grouped by the domain concept they talk
about (deployment, telemetry, grafana) rather than by feature file, so a step
can be reused by any feature. They are registered below via pytest_plugins so
every solution shares them. API client fixtures live in clients.py
(see README.md).
"""

import pytest
from helpers import discover_solutions

pytest_plugins = [
    "clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
]

_SOLUTIONS = discover_solutions()


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

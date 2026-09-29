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

import os

import pytest
from helpers import discover_solutions

pytest_plugins = [
    "clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
    "steps.tls",
]

_SOLUTIONS = discover_solutions()

# Which mode the wrapper Terraform was applied with; set by solution.just,
# same value the spread task variant used to pick a tfvar (see spread.yaml).
_MODES = frozenset({"tls_internal", "tls_none"})
_ACTIVE_MODE = os.environ.get("SOLUTION_MODE", "tls_internal")


def pytest_configure(config: pytest.Config) -> None:
    for solution in _SOLUTIONS:
        config.addinivalue_line("markers", f"{solution}: scenario only applies to the '{solution}' solution")
    for mode in _MODES:
        config.addinivalue_line("markers", f"{mode}: scenario only applies to the '{mode}' mode")


def pytest_collection_modifyitems(config: pytest.Config, items: list[pytest.Item]) -> None:
    """Deselect scenarios tagged for a solution or mode other than the one under test."""
    kept, deselected = [], []
    for item in items:
        solution = item.path.parent.name
        tags = {mark.name for mark in item.iter_markers()}
        wrong_solution = bool(tags & _SOLUTIONS) and solution not in tags
        wrong_mode = bool(tags & _MODES) and _ACTIVE_MODE not in tags
        (deselected if wrong_solution or wrong_mode else kept).append(item)
    if deselected:
        config.hook.pytest_deselected(items=deselected)
        items[:] = kept

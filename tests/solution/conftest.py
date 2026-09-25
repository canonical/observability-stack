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

# Mode tags aren't discovered from a directory layout; add new values here.
_MODES = frozenset({"tls-internal", "tls-none"})

_DEFAULT_MODE = "tls-internal"
_ACTIVE_MODES = frozenset((os.environ.get("SOLUTION_MODES") or _DEFAULT_MODE).split(","))


def pytest_configure(config: pytest.Config) -> None:
    for solution in _SOLUTIONS:
        config.addinivalue_line("markers", f"{solution}: scenario only applies to the '{solution}' solution")
    for mode in _MODES:
        config.addinivalue_line("markers", f"{mode}: scenario only applies to the '{mode}' mode")


def pytest_collection_modifyitems(config: pytest.Config, items: list[pytest.Item]) -> None:
    """Deselect scenarios tagged for a solution, or mode, other than the one under test."""
    kept, deselected = [], []
    for item in items:
        solution = item.path.parent.name
        tags = {mark.name for mark in item.iter_markers()}
        solution_tags = tags & _SOLUTIONS
        mode_tags = tags & _MODES
        wrong_solution = bool(solution_tags) and solution not in solution_tags
        wrong_mode = bool(mode_tags) and not (mode_tags & _ACTIVE_MODES)
        (deselected if wrong_solution or wrong_mode else kept).append(item)
    if deselected:
        config.hook.pytest_deselected(items=deselected)
        items[:] = kept

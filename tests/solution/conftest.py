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
from helpers import discover_modes, discover_solutions

pytest_plugins = [
    "clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
    "steps.tls",
]

# Two independent tag axes, each deselected the same way: a scenario tagged
# with one or more values from an axis only runs where its ancestor
# directory matches one of those values; untagged scenarios run everywhere.
_AXES = {
    "solution": discover_solutions(),  # e.g. @cos-lite, matched against tests/solution/cos-lite/...
    "mode": discover_modes(),  # e.g. @tls_internal, matched against .../cos-lite/tls_internal/...
}


def pytest_configure(config: pytest.Config) -> None:
    for axis, values in _AXES.items():
        for value in values:
            config.addinivalue_line("markers", f"{value}: scenario only applies to the '{value}' {axis}")


def _ancestor_dir_names(item: pytest.Item) -> set[str]:
    return {parent.name for parent in item.path.parents}


def pytest_collection_modifyitems(config: pytest.Config, items: list[pytest.Item]) -> None:
    """Deselect scenarios tagged for an axis value other than the item's own.

    Every solution/mode loads every shared feature file (see each
    test_solution.py); an untagged scenario runs everywhere, one tagged e.g.
    `@cos-lite` or `@tls_internal` runs only under a directory with that name
    (at any depth, so a mode tag still works nested under a solution dir and
    vice versa).
    """
    kept, deselected = [], []
    for item in items:
        ancestors = _ancestor_dir_names(item)
        tags = {mark.name for mark in item.iter_markers()}
        mismatched = any(
            (axis_tags := tags & values) and not axis_tags & ancestors for values in _AXES.values()
        )
        (deselected if mismatched else kept).append(item)
    if deselected:
        config.hook.pytest_deselected(items=deselected)
        items[:] = kept

#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: step registration and mode deselection."""

import os

import pytest

pytest_plugins = [
    "clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
    "steps.tls",
]

# Which mode the wrapper Terraform was applied with; set by solution.just,
# same value the spread task variant used to pick a tfvar (see spread.yaml).
_MODES = frozenset({"tls_internal", "tls_none"})
_ACTIVE_MODE = os.environ.get("SOLUTION_MODE", "tls_internal")


def pytest_configure(config: pytest.Config) -> None:
    for mode in _MODES:
        config.addinivalue_line("markers", f"{mode}: scenario only applies to the '{mode}' mode")


def pytest_collection_modifyitems(config: pytest.Config, items: list[pytest.Item]) -> None:
    """Deselect scenarios tagged for a mode other than the one under test."""
    kept, deselected = [], []
    for item in items:
        tags = {mark.name for mark in item.iter_markers()}
        wrong_mode = bool(tags & _MODES) and _ACTIVE_MODE not in tags
        (deselected if wrong_mode else kept).append(item)
    if deselected:
        config.hook.pytest_deselected(items=deselected)
        items[:] = kept

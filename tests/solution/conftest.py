#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: step registration and the deployment fixtures."""

import os
from pathlib import Path

import jubilant
import pytest

from helpers import Mode, deployment_mode

# Step definitions shared by the feature files, grouped by topic.
pytest_plugins = [
    "steps.clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
    "steps.tls",
]


@pytest.fixture(scope="module")
def solution_dir(request) -> Path:
    """The directory of the solution the test module belongs to."""
    return Path(request.module.__file__).parent


@pytest.fixture(scope="module")
def juju(solution_dir: Path) -> jubilant.Juju:
    """The model `just solution test` deployed the solution into.

    That's SOLUTION_MODEL (optionally `<controller>:<model>`), else the solution's directory name,
    which its Terraform wrapper names the model after.
    """
    return jubilant.Juju(model=os.environ.get("SOLUTION_MODEL", solution_dir.name))


@pytest.fixture(scope="module")
def mode(solution_dir: Path) -> Mode:
    """The mode the solution was deployed in, from its Terraform wrapper's outputs."""
    return deployment_mode(solution_dir / "terraform")

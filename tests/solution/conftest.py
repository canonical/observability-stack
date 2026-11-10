#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: step registration and the deployment fixtures."""

import json
import os
from pathlib import Path

import jubilant
import pytest

from helpers import Mode, deployment_mode, mode_from_outputs

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
    """The mode the solution was deployed in, from its Terraform wrapper's outputs.

    For a deployment the wrapper didn't make (e.g. SolQA's, see `sqa_tests`), SOLUTION_MODE
    states the mode instead: a JSON object of the wrapper's output values, keyed by output name.
    """
    if "SOLUTION_MODE" in os.environ:
        return mode_from_outputs(json.loads(os.environ["SOLUTION_MODE"]))
    return deployment_mode(solution_dir / "terraform")

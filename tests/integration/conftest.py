#!/usr/bin/env python3
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.
"""Conftest file for integration tests."""

import os

import jubilant
import pytest
from helpers import TfDirManager


def pytest_addoption(parser):
    parser.addoption(
        "--keep-models",
        action="store_true",
        default=False,
        help="Keep temporarily-created models instead of destroying them after the tests run.",
    )


def _keep_models(request) -> bool:
    """Whether to keep temporary models, via CLI flag or the KEEP_MODELS env var."""
    return bool(request.config.getoption("--keep-models")) or (
        os.environ.get("KEEP_MODELS") is not None
    )


@pytest.fixture(scope="module")
def ca_model(request):
    with jubilant.temp_model(keep=_keep_models(request)) as juju:
        yield juju


@pytest.fixture(scope="module")
def cos_model(request):
    with jubilant.temp_model(keep=_keep_models(request)) as juju:
        yield juju


@pytest.fixture(scope="module")
def tf_manager(tmp_path_factory):
    base = tmp_path_factory.mktemp("terraform_base")
    return TfDirManager(base)

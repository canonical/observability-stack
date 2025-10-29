#!/usr/bin/env python3
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.
"""Conftest file for integration tests."""

import os

import jubilant
import pytest
from helpers import TfDirManager


@pytest.fixture(scope="module")
def ca_model():
    keep_models: bool = os.environ.get("KEEP_MODELS") is not None
    with jubilant.temp_model(keep=keep_models) as juju:
        yield juju


@pytest.fixture(scope="module")
def cos_model():
    keep_models: bool = os.environ.get("KEEP_MODELS") is not None
    with jubilant.temp_model(keep=keep_models) as juju:
        yield juju


@pytest.fixture(scope="module")
def tf_manager(tmp_path_factory):
    base = tmp_path_factory.mktemp("terraform_base")
    return TfDirManager(base)

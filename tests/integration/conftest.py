#!/usr/bin/env python3
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.
"""Conftest file for integration tests."""

import logging
import os
import secrets
import subprocess

import jubilant
import pytest
from helpers import TfDirManager

logger = logging.getLogger(__name__)


def _model(name: str, keep: bool = False):
    juju = jubilant.Juju()
    juju.add_model(f"{name}-jubilant-" + secrets.token_hex(4))
    try:
        yield juju
    finally:
        if not keep:
            assert juju.model is not None
            try:
                # We're not using juju.destroy_model() here, as Juju doesn't provide a way
                # to specify the timeout for the entire model destruction operation.
                args = [
                    "destroy-model",
                    juju.model,
                    "--no-prompt",
                    "--destroy-storage",
                    "--force",
                ]
                juju._cli(*args, include_model=False, timeout=10 * 60)
                juju.model = None
            except subprocess.TimeoutExpired as exc:
                logger.error(
                    "timeout destroying model: %s\nStdout:\n%s\nStderr:\n%s",
                    exc,
                    exc.stdout,
                    exc.stderr,
                )


@pytest.fixture(scope="module")
def ca_model():
    yield from _model(name="ca", keep=os.environ.get("KEEP_MODELS") is not None)


@pytest.fixture(scope="module")
def cos_model():
    yield from _model(name="cos", keep=os.environ.get("KEEP_MODELS") is not None)


@pytest.fixture(scope="module")
def cos_lite_model():
    yield from _model(name="cos-lite", keep=os.environ.get("KEEP_MODELS") is not None)


@pytest.fixture(scope="module")
def tf_manager(tmp_path_factory):
    base = tmp_path_factory.mktemp("terraform_base")
    return TfDirManager(base)

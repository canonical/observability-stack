#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Steps for features/alerting.feature."""

from pytest_bdd import given


@given("Avalanche is integrated with the solution")
def avalanche_is_integrated(avalanche: None) -> None:
    """Deployed and integrated by the `avalanche` fixture in conftest.py."""

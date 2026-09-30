#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: step registration."""

pytest_plugins = [
    "clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
    "steps.tls",
]

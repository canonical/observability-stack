#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: step registration, CLI options."""

pytest_plugins = [
    "clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
    "steps.tls",
]


def pytest_addoption(parser):
    parser.addoption(
        "--internal-tls",
        default="",
        choices=["", "true", "false"],
        help="Empty uses the Terraform wrapper's own default (true).",
    )
    parser.addoption(
        "--external-ca",
        default="",
        choices=["", "true", "false"],
        help="Empty uses the Terraform wrapper's own default (false).",
    )
    parser.addoption(
        "--ingress",
        default="",
        choices=["", "true", "false"],
        help="Empty uses the Terraform wrapper's own default (true).",
    )

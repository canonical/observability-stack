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
        "--tls-mode",
        default="",
        choices=["", "tls_none", "tls_internal", "tls_full", "tls_external"],
        help="Empty uses the Terraform wrapper's own default (tls_internal).",
    )
    parser.addoption(
        "--ingress-mode",
        default="",
        choices=["", "ingress", "no_ingress"],
        help="Empty uses the Terraform wrapper's own default (ingress on).",
    )

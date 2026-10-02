#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared pytest config for solution tests: step registration, CLI options."""

pytest_plugins = [
    "clients",
    "steps.deployment",
    "steps.grafana",
    "steps.telemetry",
]


def pytest_addoption(parser):
    parser.addoption(
        "--tls-mode",
        default="",
        help="One of tls_none, tls_internal, tls_full, tls_external. "
        "Empty uses the Terraform wrapper's own default (tls_internal).",
    )
    parser.addoption(
        "--ingress-mode",
        default="",
        help="One of ingress, no_ingress. Empty uses the Terraform "
        "wrapper's own default (ingress on).",
    )

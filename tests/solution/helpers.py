# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared helpers for solution smoke tests."""

import json
import os
import subprocess
from pathlib import Path
from typing import Any, Dict

import jubilant
import requests

SOLUTION_ROOT = Path(__file__).parent

# Resolved terraform/tofu binary, set by quality-gates.just; falls back to
# "terraform" when running pytest directly.
TERRAFORM_BIN = os.environ.get("terraform") or "terraform"


def discover_solutions() -> frozenset[str]:
    """Every solution name under tests/solution/.

    A solution is a top-level dir with a terraform/ subdir, either directly
    or one level down under per-mode dirs (tests/solution/<solution>/<mode>/terraform/).
    """
    return frozenset(
        p.name
        for p in SOLUTION_ROOT.iterdir()
        if p.is_dir()
        and (
            (p / "terraform").is_dir()
            or any((mode / "terraform").is_dir() for mode in p.iterdir() if mode.is_dir())
        )
    )


def discover_modes() -> frozenset[str]:
    """Every mode name under tests/solution/<solution>/<mode>/.

    A mode is a dir one level under a solution dir with its own terraform/
    subdir (tests/solution/<solution>/<mode>/terraform/), e.g. `tls_internal`.
    """
    return frozenset(
        mode.name
        for solution in SOLUTION_ROOT.iterdir()
        if solution.is_dir()
        for mode in solution.iterdir()
        if mode.is_dir() and (mode / "terraform").is_dir()
    )


def terraform_output(terraform_dir: Path) -> Dict[str, Any]:
    """Return `terraform output -json` for an already-applied module."""
    result = subprocess.run(
        [TERRAFORM_BIN, f"-chdir={terraform_dir}", "output", "-json"],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def wait_for_active_idle(juju: jubilant.Juju, timeout: int = 60 * 45):
    """Wait for every application to be active, then every agent to be idle."""
    print(f"\nwaiting for the model ({juju.model}) to settle ...\n")
    juju.wait(jubilant.all_active, delay=10, timeout=timeout)
    print("\nwaiting for agents idle ...\n")
    juju.wait(
        jubilant.all_agents_idle,
        delay=10,
        timeout=timeout,
        error=jubilant.any_error,
    )


def unit_url(juju: jubilant.Juju, app: str, port: int) -> str:
    """Base URL of an application's first unit, picking the scheme it actually serves.

    Solutions enable internal TLS by default, but that is configurable, so the
    scheme is probed rather than assumed.
    """
    status = juju.status()
    address = next(iter(status.apps[app].units.values())).address
    for scheme in ("https", "http"):
        url = f"{scheme}://{address}:{port}"
        try:
            requests.get(url, timeout=30, verify=False)
        except requests.RequestException:
            continue
        return url
    raise AssertionError(f"no reachable {app} workload at {address}:{port}")

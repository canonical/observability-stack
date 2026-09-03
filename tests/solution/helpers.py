# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared helpers for solution smoke tests."""

import json
import os
import subprocess
from pathlib import Path
from typing import Any, Dict

import jubilant

SOLUTION_ROOT = Path(__file__).parent

# Resolved terraform/tofu binary, set by quality-gates.just; falls back to
# "terraform" when running pytest directly.
TERRAFORM_BIN = os.environ.get("terraform") or "terraform"


def discover_solutions() -> frozenset[str]:
    """Every solution name under tests/solution/ (any dir with a terraform/ subdir)."""
    return frozenset(p.name for p in SOLUTION_ROOT.iterdir() if (p / "terraform").is_dir())


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

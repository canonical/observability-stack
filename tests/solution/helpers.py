# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared helpers for solution smoke tests."""

import json
import os
import shlex
import shutil
import subprocess
import time
from pathlib import Path
from typing import Any, Dict, Optional, Sequence

import jubilant
import requests

# Resolved terraform/tofu binary, set by quality-gates.just; falls back to
# "terraform" when running pytest directly.
TERRAFORM_BIN = os.environ.get("terraform") or "terraform"

# How far back to look for logs and traces.
LOOKBACK_HOURS = 24


class TfDirManager:
    # Duplicated in tests/integration/helpers.py: the two pytest roots don't
    # share a package, and this is small enough not to be worth a shared
    # module. Keep both copies in sync by hand.
    def __init__(self, base_tmpdir=None, dir: Optional[str] = None):
        self.base: str = str(base_tmpdir) if base_tmpdir is not None else ""
        self.dir: str = dir or ""

    @property
    def tf_cmd(self):
        return f"terraform -chdir={self.dir}"

    def init(self, tf_file: Optional[str] = None):
        """Initialize a Terraform module, copying `tf_file` in if given."""
        if tf_file is not None:
            self.dir = os.path.join(self.base, "terraform")
            os.makedirs(self.dir, exist_ok=True)
            shutil.copy(tf_file, os.path.join(self.dir, "main.tf"))
        subprocess.run(shlex.split(f"{self.tf_cmd} init -upgrade"), check=True)

    @staticmethod
    def _args_str(
        target: Optional[str] = None,
        var_files: Sequence[str] = (),
        **kwargs,
    ) -> str:
        target_arg = f"-target module.{target}" if target else ""
        var_file_args = " ".join(f"-var-file {f}" for f in var_files)
        var_args = " ".join(f"-var {k}={v}" for k, v in kwargs.items())
        return f"-auto-approve {target_arg} {var_file_args} {var_args}"

    def apply(
        self,
        target: Optional[str] = None,
        var_files: Sequence[str] = (),
        **kwargs,
    ):
        cmd_str = f"{self.tf_cmd} apply " + self._args_str(
            target, var_files, **kwargs
        )
        subprocess.run(shlex.split(cmd_str), check=True)

    def destroy(self, var_files: Sequence[str] = (), **kwargs):
        cmd_str = f"{self.tf_cmd} destroy " + self._args_str(
            None, var_files, **kwargs
        )
        subprocess.run(shlex.split(cmd_str), check=True)


def lookback_window_ns() -> tuple[int, int]:
    """Return the (start, end) of the lookback window, in nanoseconds since the epoch."""
    end = time.time_ns()
    return end - LOOKBACK_HOURS * 3600 * 1_000_000_000, end


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


def leader_unit(juju: jubilant.Juju, app: str) -> str:
    """Name of the leader unit of an application."""
    for name, unit in juju.status().apps[app].units.items():
        if unit.leader:
            return name
    raise AssertionError(f"no leader unit found for application '{app}'")


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

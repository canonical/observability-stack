# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared helpers for solution smoke tests."""

import json
import os
import pytest
import shlex
import shutil
import ssl
import subprocess
import tempfile
import threading
import time
from pathlib import Path
from typing import Any, Callable, Dict, Optional, Sequence

import jubilant
import requests
from tenacity import RetryError, Retrying, retry_if_result, stop_after_delay, wait_fixed

# Resolved terraform/tofu binary, set by quality-gates.just; falls back to
# "terraform" when running pytest directly.
TERRAFORM_BIN = os.environ.get("terraform") or "terraform"

# How far back to look for logs and traces.
LOOKBACK_HOURS = 24

# Ports the workloads' own APIs listen on, shared by clients.py's fixtures and
# steps/tls.py's port lookup.
_PORTS = {
    "alertmanager": 9093,
    "grafana": 3000,
    "loki": 3100,
    "mimir": 8080,
    "prometheus": 9090,
    "tempo": 3200,
}


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


def retry_until_found(check: Callable[[], bool]) -> bool:
    """Retry `check` for up to two minutes, polling every ten seconds.

    Scraping/ingestion is periodic, so the first samples for an application
    can land a little after the model has settled into active/idle.
    """
    retrying = Retrying(
        retry=retry_if_result(lambda result: result is False),
        wait=wait_fixed(10),
        stop=stop_after_delay(60 * 2),
    )
    try:
        return retrying(check)
    except RetryError:
        return False


def terraform_dir(request) -> Path:
    """Terraform wrapper directory for the solution a test module belongs to."""
    return Path(request.module.__file__).parent / "terraform"


def terraform_output(terraform_dir: Path) -> Dict[str, Any]:
    """Return `terraform output -json` for an already-applied module."""
    result = subprocess.run(
        [TERRAFORM_BIN, f"-chdir={terraform_dir}", "output", "-json"],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def wait_for_active_idle(
    juju: jubilant.Juju, timeout: int = 60 * 45, status_interval: int = 60
):
    """Wait for every application to be active, then every agent to be idle.

    This 45-minute wait can span most of a CI job, and GitHub's job-level
    timeout cancels the whole job (rather than letting pytest time out and
    report a traceback) if it's ever reached -- which previously left zero
    debugging information behind ("model never settles", CI_FAILURES_modes.md).
    To make sure a cancelled job still has something to diagnose, this dumps
    `juju status` and recent `debug-log` output to stdout every
    `status_interval` seconds while waiting, instead of only noting the
    final status on a `TimeoutError` nothing ever gets to print.
    """
    print(f"\nwaiting for the model ({juju.model}) to settle ...\n", flush=True)
    _wait_dumping_status(juju, jubilant.all_active, "active", timeout, status_interval)
    print("\nwaiting for agents idle ...\n", flush=True)
    _wait_dumping_status(
        juju,
        jubilant.all_agents_idle,
        "idle",
        timeout,
        status_interval,
        error=jubilant.any_error,
    )


def _wait_dumping_status(
    juju: jubilant.Juju,
    ready: Callable[[jubilant.Status], bool],
    label: str,
    timeout: int,
    status_interval: int,
    **wait_kwargs,
) -> None:
    """Like `juju.wait()`, but dumps status periodically instead of silently.

    A single call to `juju.wait()` only requires `successes` *consecutive*
    passes of `ready`, so chunking it into repeated shorter-timeout calls
    (tried first, see git history) resets that streak every chunk and can
    spin forever even once the model is genuinely settled -- never do that
    again. Instead, run the *real* `juju.wait()` call once, with the full
    `timeout`, and dump `juju status`/`debug-log` from a background thread
    every `status_interval` seconds while it runs, so CI's *live* log has
    something to show even if the job gets cancelled before `juju.wait()`
    itself ever gets a chance to raise (and print) its `TimeoutError`.
    """
    stop = threading.Event()

    def _periodic_dump():
        while not stop.wait(status_interval):
            _dump_status(juju, label)

    dumper = threading.Thread(target=_periodic_dump, daemon=True)
    dumper.start()
    try:
        juju.wait(ready, delay=10, timeout=timeout, **wait_kwargs)
    except TimeoutError:
        _dump_status(juju, label)
        raise
    finally:
        stop.set()
        dumper.join(timeout=5)


def _dump_status(juju: jubilant.Juju, label: str) -> None:
    """Print `juju status` and recent `debug-log` for live CI debugging."""
    print(f"\n--- still waiting for all-{label} (model={juju.model}) ---", flush=True)
    try:
        print(juju.cli("status", "--relations"), flush=True)
    except subprocess.CalledProcessError as exc:
        print(f"(juju status failed: {exc})", flush=True)
    try:
        print(juju.debug_log(limit=200), flush=True)
    except subprocess.CalledProcessError as exc:
        print(f"(juju debug-log failed: {exc})", flush=True)
    print(f"--- end status dump (still waiting for all-{label}) ---\n", flush=True)


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


def ingressed_url(juju: jubilant.Juju, request, app: str, port: int) -> Optional[str]:
    """Base URL of an application's ingress route, when its ingress is enabled.

    Returns None when not ingressed, so the caller can fall back to unit_url.
    """
    ingress = terraform_output(terraform_dir(request))["ingress"]["value"]
    if not ingress.get(app):
        return None

    proxied_endpoints = json.loads(
        juju.run("traefik/leader", "show-proxied-endpoints").results[
            "proxied-endpoints"
        ]
    )
    entry = proxied_endpoints.get(app) or proxied_endpoints.get(leader_unit(juju, app))
    return entry["url"] if entry else None


def get_tls_context(juju: jubilant.Juju, ca_name: str) -> Optional[ssl.SSLContext]:
    # Duplicated in tests/integration/helpers.py, adapted to not need a
    # caller-supplied temp_path. See TfDirManager above for why.
    if ca_name not in juju.status().apps:
        return None

    cert = juju.run(f"{ca_name}/0", "get-ca-certificate").results["ca-certificate"]
    with tempfile.NamedTemporaryFile(mode="w", suffix=".pem") as cert_file:
        cert_file.write(cert)
        cert_file.flush()
        ctx = ssl.create_default_context()
        ctx.load_verify_locations(cert_file.name)
    return ctx


def _skip_if_not_deployed(juju: jubilant.Juju, application: str) -> None:
    """Skip the current scenario when `application` isn't part of this deployment."""
    if application not in juju.status().apps:
        pytest.skip(f"'{application}' is not deployed in this solution's current mode")

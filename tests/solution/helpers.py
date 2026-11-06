# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared helpers for solution smoke tests."""

import functools
import json
import os
import pytest
import socket
import ssl
import subprocess
import tempfile
import time
from pathlib import Path
from typing import Any, Callable, Dict, Optional

import jubilant
import requests
from tenacity import RetryError, Retrying, retry_if_result, stop_after_delay, wait_fixed

# Resolved terraform/tofu binary, set by solution.just; falls back to
# "terraform" when running pytest directly.
TERRAFORM_BIN = os.environ.get("terraform") or "terraform"

# Points the tests at an already-deployed model instead of the Terraform
# wrapper's; Terraform isn't run at all then (see README.md).
_MODEL_ENV_VAR = "SOLUTION_MODEL"

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


def mode_options(request) -> Dict[str, str]:
    """The --internal-tls, --external-ca and --ingress options ("" means the wrapper's default)."""
    options = {
        "internal_tls": request.config.getoption("--internal-tls"),
        "external_ca": request.config.getoption("--external-ca"),
        "ingress": request.config.getoption("--ingress"),
    }
    if options["external_ca"] == "true" and options["ingress"] == "false":
        pytest.fail(
            "--external-ca=true with --ingress=false isn't an allowed combination."
        )
    return options


def deployment_mode(request) -> Dict[str, Any]:
    """The mode the steps expect the deployment to be in.

    Read from the wrapper's Terraform outputs, or with SOLUTION_MODEL, from the
    mode options, so an external suite needs no Terraform state. Per-component
    ingress isn't known then (None); `app_url` asks Traefik instead.
    """
    if _MODEL_ENV_VAR not in os.environ:
        outputs = terraform_output(terraform_dir(request))
        keys = ("internal_tls", "tls_termination", "ingress", "optional_apps")
        mode = {key: outputs[key]["value"] for key in keys}
        # Terraform leaves null outputs out, and ca_model_name is null without an external CA.
        mode["ca_model_name"] = outputs.get("ca_model_name", {}).get("value")
        return mode

    options = mode_options(request)
    if options["external_ca"] == "true":
        # The external-CA step gets its CA from the wrapper's own CA model.
        pytest.fail(f"--external-ca=true isn't supported with {_MODEL_ENV_VAR} yet.")
    return {
        "internal_tls": options["internal_tls"] != "false",
        "tls_termination": False,
        "ca_model_name": None,
        "ingress": None,
        "optional_apps": {"traefik": options["ingress"] != "false"},
    }


# Every scenario's `Background` calls `wait_for_active_idle` again for the
# same already-applied model - cache a confirmed failure so later scenarios
# don't each take the full timeout on a stuck model.
_settled: Dict[str, Exception] = {}


def wait_for_active_idle(juju: jubilant.Juju, timeout: int = 60 * 45):
    """Wait for every application to be active, then every agent to be idle."""
    if juju.model in _settled:
        # Already confirmed stuck - don't wait until the timeout.
        raise _settled[juju.model]

    try:
        print(f"\nwaiting for the model ({juju.model}) to settle ...\n", flush=True)
        juju.wait(jubilant.all_active, delay=10, timeout=timeout)
        print("\nwaiting for agents idle ...\n", flush=True)
        juju.wait(
            jubilant.all_agents_idle,
            delay=10,
            timeout=timeout,
            error=jubilant.any_error,
        )
    except Exception as exc:
        _settled[juju.model] = exc
        raise


def leader_unit(juju: jubilant.Juju, app: str) -> str:
    """Name of the leader unit of an application."""
    for name, unit in juju.status().apps[app].units.items():
        if unit.leader:
            return name
    raise AssertionError(f"no leader unit found for application '{app}'")


@functools.cache
def _proxied_endpoints(model: str) -> Dict[str, Any]:
    """Traefik's ingress URLs, keyed by application (or by unit, for per-unit ingress).

    Empty when the model has no Traefik. Cached per model, so the action runs once.
    """
    juju = jubilant.Juju(model=model)
    if "traefik" not in juju.status().apps:
        return {}
    task = juju.run(leader_unit(juju, "traefik"), "show-proxied-endpoints")
    return json.loads(task.results["proxied-endpoints"])


def ingressed_url(juju: jubilant.Juju, app: str) -> Optional[str]:
    """Base URL of an application's ingress route, or None if Traefik has no route for it."""
    endpoints = _proxied_endpoints(juju.model)
    for key in sorted(endpoints):
        if key == app or key.startswith(f"{app}/"):
            return endpoints[key]["url"].rstrip("/")
    return None


def app_url(juju: jubilant.Juju, app: str, port: int) -> str:
    """Base URL of an application: through Traefik if it's ingressed, else its first unit.

    Through Traefik, only the load balancer address has to be reachable from
    where the tests run, not the pods.
    """
    return ingressed_url(juju, app) or unit_url(juju, app, port)


def unit_url(juju: jubilant.Juju, app: str, port: int) -> str:
    """Base URL of an application's first unit, picking the scheme it actually serves."""
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


def get_tls_context(juju: jubilant.Juju, ca_name: str) -> Optional[ssl.SSLContext]:
    # Duplicated in tests/integration/helpers.py, adapted to not need a
    # caller-supplied temp_path: the two pytest roots don't share a package.
    if ca_name not in juju.status().apps:
        return None

    cert = juju.run(f"{ca_name}/0", "get-ca-certificate").results["ca-certificate"]
    with tempfile.NamedTemporaryFile(mode="w", suffix=".pem") as cert_file:
        cert_file.write(cert)
        cert_file.flush()
        ctx = ssl.create_default_context()
        ctx.load_verify_locations(cert_file.name)
    return ctx


def tls_handshake_error(
    address: str, port: int, server_hostname: str, ctx: ssl.SSLContext
) -> Optional[str]:
    """Try a TLS handshake that verifies the peer's certificate against `ctx`.

    Returns None if it succeeds, else the TLS error, so the caller's assertion
    can say why (an unknown CA and a hostname mismatch need different fixes).
    """
    try:
        with (
            socket.create_connection((address, port), timeout=30) as sock,
            ctx.wrap_socket(sock, server_hostname=server_hostname),
        ):
            return None
    except ssl.SSLError as exc:
        return str(exc)


def _expect_deployed(juju: jubilant.Juju, request, application: str) -> None:
    """Skip if this mode doesn't deploy `application`, fail if it should but isn't."""
    optional = deployment_mode(request)["optional_apps"]
    if optional.get(application) is False:
        pytest.skip(f"'{application}' is not deployed in this solution's current mode")
    assert application in juju.status().apps, (
        f"'{application}' should be deployed in this mode but isn't in the model"
    )

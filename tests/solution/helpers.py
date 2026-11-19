# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Helpers shared by the solution tests' fixtures and steps."""

import json
import os
import socket
import ssl
import subprocess
import time
from pathlib import Path
from typing import Any, Dict, NamedTuple, Optional

import jubilant
import requests

# Resolved terraform/tofu binary, set by solution.just; falls back to
# "terraform" when running pytest directly.
TERRAFORM_BIN = os.environ.get("terraform") or "terraform"

# How far back to look for logs and traces.
LOOKBACK_HOURS = 24

# Ports the workloads' own APIs listen on.
PORTS = {
    "alertmanager": 9093,
    "grafana": 3000,
    "loki": 3100,
    "mimir": 8080,
    "prometheus": 9090,
    "tempo": 3200,
}


class Mode(NamedTuple):
    """How the Terraform wrapper deployed the solution (see the wrapper's outputs.tf)."""

    internal_tls: bool
    external_ca: bool
    ca_model_name: Optional[str]  # the model the external CA lives in
    ingress: Dict[str, bool]  # per component
    traefik: bool


def lookback_window_ns() -> tuple[int, int]:
    """Return the (start, end) of the lookback window, in nanoseconds since the epoch."""
    end = time.time_ns()
    return end - LOOKBACK_HOURS * 3600 * 1_000_000_000, end


def deployment_mode(terraform_dir: Path) -> Mode:
    """The mode of an already-applied Terraform wrapper, from its outputs."""
    result = subprocess.run(
        [TERRAFORM_BIN, f"-chdir={terraform_dir}", "output", "-json"],
        check=True,
        capture_output=True,
        text=True,
    )
    outputs = {
        name: output["value"] for name, output in json.loads(result.stdout).items()
    }
    return Mode(
        internal_tls=outputs["internal_tls"],
        external_ca=outputs["tls_termination"],
        # Not an output at all when null, i.e. without an external CA.
        ca_model_name=outputs.get("ca_model_name"),
        ingress=outputs["ingress"],
        traefik=outputs["optional_apps"]["traefik"],
    )


def leader_unit(juju: jubilant.Juju, app: str) -> str:
    """Name of the leader unit of an application."""
    for name, unit in juju.status().apps[app].units.items():
        if unit.leader:
            return name
    raise AssertionError(f"no leader unit found for application '{app}'")


def model_namespace(juju: jubilant.Juju) -> str:
    """The Kubernetes namespace of the model, which `juju.model` may prefix with its controller."""
    assert juju.model, "Juju model not set"
    return juju.model.rpartition(":")[-1]


def unit_fqdn(juju: jubilant.Juju, unit_name: str) -> str:
    """The in-cluster FQDN of a unit, which its server certificate is issued for."""
    app, _, number = unit_name.partition("/")
    return f"{app}-{number}.{app}-endpoints.{model_namespace(juju)}.svc.cluster.local"


def ingressed_url(proxied_endpoints: Dict[str, Any], app: str) -> Optional[str]:
    """Base URL of an application's ingress route, or None if Traefik has no route for it.

    `proxied_endpoints` is keyed by application (or by unit, for per-unit ingress).
    """
    for key in sorted(proxied_endpoints):
        if key == app or key.startswith(f"{app}/"):
            return proxied_endpoints[key]["url"].rstrip("/")
    return None


def unit_url(juju: jubilant.Juju, app: str) -> str:
    """Base URL of an application's first unit, picking the scheme it actually serves."""
    address = next(iter(juju.status().apps[app].units.values())).address
    for scheme in ("https", "http"):
        url = f"{scheme}://{address}:{PORTS[app]}"
        try:
            requests.get(url, timeout=30, verify=False)
        except requests.RequestException:
            continue
        return url
    raise AssertionError(f"no reachable {app} workload at {address}:{PORTS[app]}")


def app_url(juju: jubilant.Juju, proxied_endpoints: Dict[str, Any], app: str) -> str:
    """Base URL of an application: through Traefik if it's ingressed, else its first unit.

    Through Traefik, only the load balancer address has to be reachable from
    where the tests run, not the pods.
    """
    return ingressed_url(proxied_endpoints, app) or unit_url(juju, app)


def ca_context(juju: jubilant.Juju, ca_app: str) -> ssl.SSLContext:
    """A TLS context that trusts only the CA certificate of a self-signed-certificates app."""
    certificate = juju.run(f"{ca_app}/0", "get-ca-certificate").results[
        "ca-certificate"
    ]
    return ssl.create_default_context(cadata=certificate)


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

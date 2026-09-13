# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Shared helpers for the solution tests."""

import json
import os
import subprocess
import time
from pathlib import Path
from typing import Any, Callable, Dict

import jubilant
from tenacity import (
    RetryError,
    retry,
    retry_if_exception_type,
    retry_if_not_result,
    stop_after_delay,
    wait_fixed,
)

SOLUTION_ROOT = Path(__file__).parent

# Resolved terraform/tofu binary, set by solution.just; falls back to
# "terraform" when running pytest directly.
TERRAFORM_BIN = os.environ.get("terraform") or "terraform"

# Points the tests at an already-deployed model instead of discovering one
# from `terraform output` (see README.md).
MODEL_ENV_VAR = "SOLUTION_MODEL"

LOG_LOOKBACK_S = 60 * 60


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


def resolve_model_name(solution_dir: Path) -> str:
    """The model a solution's tests run against.

    `$SOLUTION_MODEL` if set, otherwise the `model_name` output of the
    solution's terraform module under `solution_dir`.
    """
    model_name = os.environ.get(MODEL_ENV_VAR)
    if model_name:
        return model_name
    return terraform_output(solution_dir / "terraform")["model_name"]["value"]


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


def eventually(
    check: Callable[..., bool], *args: Any, timeout: float = 300, interval: float = 5, **kwargs: Any
) -> bool:
    """Call `check` until it returns True; False if it never does within `timeout` seconds."""
    policy = retry(
        retry=retry_if_not_result(bool) | retry_if_exception_type(),
        stop=stop_after_delay(timeout),
        wait=wait_fixed(interval),
        reraise=True,
    )
    try:
        return policy(check)(*args, **kwargs)
    except RetryError:
        return False


def promql_has_result(prometheus, promql: str) -> bool:
    """Whether an instant PromQL query returns at least one series."""
    return bool(prometheus.query(promql)["data"]["result"])


def logql_has_result(loki, logql: str, lookback_s: int = LOG_LOOKBACK_S) -> bool:
    """Whether a LogQL range query over the last `lookback_s` seconds returns at least one stream."""
    end_ns = time.time_ns()
    start_ns = end_ns - lookback_s * 1_000_000_000
    return bool(loki.query_range(logql, start=str(start_ns), end=str(end_ns))["data"]["result"])


def datasources_healthy(grafana, kind: str) -> bool:
    """Whether Grafana has a datasource of type `kind` and every one of them is healthy."""
    uids = [ds["uid"] for ds in grafana.get_datasources() if ds.get("type") == kind]
    return bool(uids) and all(grafana.is_datasource_healthy(uid=uid) for uid in uids)


def app_absent(juju: jubilant.Juju, app: str) -> bool:
    return app not in juju.status().apps

import json
import logging
import os
import re
import shlex
import shutil
import ssl
import subprocess
import time
from pathlib import Path
from typing import List, Optional
from urllib.request import urlopen

import jubilant

logger = logging.getLogger(__name__)


class TfDirManager:
    def __init__(self, base_tmpdir):
        self.base: str = str(base_tmpdir)
        self.dir: str = ""

    @property
    def tf_cmd(self):
        return f"terraform -chdir={self.dir}"

    def init(self, tf_file: str):
        """Initialize a Terraform module in a subdirectory."""
        self.dir = os.path.join(self.base, "terraform")
        os.makedirs(self.dir, exist_ok=True)
        shutil.copy(tf_file, os.path.join(self.dir, "main.tf"))
        subprocess.run(shlex.split(f"{self.tf_cmd} init -upgrade"), check=True)

    @staticmethod
    def _args_str(target: Optional[str] = None, **kwargs) -> str:
        target_arg = f"-target module.{target}" if target else ""
        var_args = " ".join(f"-var {k}={v}" for k, v in kwargs.items())
        return "-auto-approve " + f"{target_arg} " + var_args

    def apply(self, target: Optional[str] = None, **kwargs):
        cmd_str = f"{self.tf_cmd} apply " + self._args_str(target, **kwargs)
        subprocess.run(shlex.split(cmd_str), check=True)

    def destroy(self, **kwargs):
        cmd_str = f"{self.tf_cmd} destroy " + self._args_str(None, **kwargs)
        subprocess.run(shlex.split(cmd_str), check=True)


def generic_assertions(
    cos_model: jubilant.Juju,
    ca_model: jubilant.Juju | None = None,
    temp_path: Path | None = None,
):
    """Generic assertions that are shared between products: cos, cos-lite"""
    if ca_model is not None and temp_path is None:
        raise ValueError("temp_path is required when ca_model is provided")
    models = [ca_model, cos_model] if ca_model is not None else [cos_model]
    wait_for_active_idle_without_error(models, timeout=60 * 60)
    tls_ctx = (
        get_tls_context(temp_path, ca_model, "self-signed-certificates")
        if ca_model is not None
        else None
    )
    catalogue_apps_are_reachable(cos_model, tls_ctx)


def wait_for_active_idle_without_error(
    jujus: List[jubilant.Juju], timeout: int = 60 * 45
):
    for juju in jujus:
        print(f"\nwaiting for the model ({juju.model}) to settle ...\n")
        juju.wait(jubilant.all_active, delay=10, timeout=timeout)
        print("\nwaiting for agents idle ...\n")
        juju.wait(
            jubilant.all_agents_idle,
            delay=10,
            timeout=timeout,
            error=jubilant.any_error,
        )


def get_tls_context(
    temp_path: Path, juju: jubilant.Juju, ca_name: str
) -> Optional[ssl.SSLContext]:
    if ca_name not in juju.status().apps:
        return None

    # Obtain certificate from external-ca
    cert_path = temp_path / "ca.pem"

    task = juju.run(f"{ca_name}/0", "get-ca-certificate", {"format": "json"})
    cert = task.results.get("ca-certificate")
    cert_path.write_text(cert)

    ctx = ssl.create_default_context()
    ctx.load_verify_locations(cert_path)
    return ctx


def catalogue_apps_are_reachable(
    juju: jubilant.Juju, tls_context: Optional[ssl.SSLContext] = None
):
    stdout = juju.ssh("catalogue/0", "cat /web/config.json", container="catalogue")
    assert stdout, "No config found in catalogue unit"
    cat_conf = json.loads(stdout)
    apps = {app["name"]: app["url"] for app in cat_conf["apps"]}
    assert apps, "No apps found in catalogue config"
    for app, url in apps.items():
        if not url:
            continue
        response = urlopen(url, data=None, timeout=2.0, context=tls_context)
        assert response.code == 200, f"{app} was not reachable"


# Pebble log format:  "PEBBLE_TS [service] OTELCOL_TS\tLEVEL\t..."
# 2026-04-22T12:08:55.177Z [otelcol] 2026-04-22T12:08:55.177Z warn memorylimiter@v0.130.1/memorylimiter.go:196 Memory usage is above hard limit. Forcing a GC. {"resource": {"service.instance.id": "9f774ce2-bbdd-44b8-95aa-abe1bd6b72eb", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "memory_limiter", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces/otelcol/0", "otelcol.signal": "traces", "cur_mem_mib": 12}
# 2026-04-22T12:00:54.179Z [otelcol] 2026-04-22T12:00:54.179Z info memorylimiter@v0.130.1/memorylimiter.go:171 Memory usage after GC. {"resource": {"service.instance.id": "9f774ce2-bbdd-44b8-95aa-abe1bd6b72eb", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "memory_limiter", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces/otelcol/0", "otelcol.signal": "traces", "cur_mem_mib": 11}
# 2026-04-22T12:08:54.309Z [otelcol] 2026-04-22T12:08:54.309Z error adapter/receiver.go:61 ConsumeLogs() failed {"resource": {"service.instance.id": "9f774ce2-bbdd-44b8-95aa-abe1bd6b72eb", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "filelog/var-log", "otelcol.component.kind": "receiver", "otelcol.signal": "logs", "error": "data refused due to high memory usage"}
_LOG_LEVEL_RE = re.compile(
    r"^\d{4}-\d{2}-\d{2}T[\d:.]+Z \[otelcol\] \d{4}-\d{2}-\d{2}T[\d:.]+Z\t(\w+)\t"  # pebble format
    r"|^\d{4}-\d{2}-\d{2}T[\d:.]+Z (\w+) "  # raw otelcol format
)


def _logs_newer_than(logs: str, timestamp: str) -> List[str]:
    """Filter log lines to only include those newer than the specified timestamp."""
    newer_logs = []
    for line in logs.splitlines():
        m = _LOG_LEVEL_RE.match(line)
        if m:
            log_ts_str = line.split(" ")[0]
            if log_ts_str > timestamp:
                newer_logs.append(line)
    return newer_logs


def no_errors_in_otelcol_logs(juju: jubilant.Juju, lookback_window: int = 60 * 5):
    """Capture only new logs for a specified duration, checking for error logs from otelcol."""
    breakpoint()
    stdout = juju.ssh("otelcol/0", "pebble logs -n 1", container="otelcol")
    assert stdout, "no logs found for otelcol"
    # TODO: Get the timestamp of the latest log to compare against future log lines
    latest_log_ts = _LOG_LEVEL_RE.match(stdout)
    logger.info(
        f"Following otelcol logs for {lookback_window} seconds to check for errors ..."
    )
    time.sleep(lookback_window)
    stdout = juju.ssh("otelcol/0", "pebble logs", container="otelcol")
    assert stdout, "no logs found for otelcol"
    logs = _logs_newer_than(stdout, latest_log_ts)
    _no_errors_in_otelcol_logs(logs)


def _no_errors_in_otelcol_logs(logs: List[str]):
    matched_lines = [
        (m.group(1) or m.group(2), line)
        for line in logs
        if (m := _LOG_LEVEL_RE.match(line))
    ]
    info_lines = [line for level, line in matched_lines if level == "info"]
    assert info_lines, "no 'info' level logs found in otelcol output"
    error_lines = [line for level, line in matched_lines if level in ("warn", "error")]
    assert not error_lines, "otelcol error logs:\n" + "\n".join(error_lines)

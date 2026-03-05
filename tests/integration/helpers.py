import json
import os
import shlex
import shutil
import ssl
import subprocess
from pathlib import Path
from typing import List, Optional
from urllib.request import urlopen

import jubilant
import pytest


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


def refresh_o11y_apps(juju: jubilant.Juju, channel: str, base: Optional[str] = None):
    """Temporary workaround for the issue:

    FIXME: https://github.com/juju/terraform-provider-juju/issues/967
    """
    for app in juju.status().apps:
        if app in {"traefik", "ca"}:
            continue
        if "s3-integrator" in app:
            continue
        juju.refresh(app, channel=channel, base=base)


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
    cat_conf = json.loads(stdout)
    apps = {app["name"]: app["url"] for app in cat_conf["apps"]}
    for app, url in apps.items():
        if not url:
            continue
        response = urlopen(url, data=None, timeout=2.0, context=tls_context)
        assert response.code == 200, f"{app} was not reachable"


@pytest.mark.skip(
    reason="""Waiting for the following issues to be resolved:
- https://github.com/canonical/cos-coordinated-workers/issues/123
- https://github.com/canonical/tempo-operators/issues/254
- https://github.com/canonical/cos-coordinated-workers/issues/115
"""
)
def no_errors_in_otelcol_logs(juju: jubilant.Juju):
    # By default, no debug exporters have been configured and otelcol logs at the WARN level
    # Thus, there should be no logs outputted if otelcol is operating correctly
    stdout = juju.ssh("otelcol/0", "pebble logs", container="otelcol")
    assert not stdout

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


def wait_for_active_idle_without_error(
    jujus: List[jubilant.Juju], timeout: int = 60 * 20
):
    for juju in jujus:
        print(f"\nwaiting for the model ({juju.model}) to settle ...\n")
        juju.wait(jubilant.all_active, delay=5, timeout=timeout)
        juju.wait(
            jubilant.all_active, delay=5, timeout=60 * 5, error=jubilant.any_error
        )
        juju.wait(
            jubilant.all_agents_idle,
            delay=5,
            timeout=60 * 5,
            error=jubilant.any_error,
        )


def get_tls_context(temp_path: Path, juju: jubilant.Juju) -> Optional[ssl.SSLContext]:
    if "ca" in juju.status().apps:
        # Obtain certificate from external-ca
        cert_path = temp_path / "ca.pem"

        task = juju.run("ca/0", "get-ca-certificate", {"format": "json"})
        cert = task.results.get("ca-certificate")
        cert_path.write_text(cert)

        ctx = ssl.create_default_context()
        ctx.load_verify_locations(cert_path)
        return ctx
    else:
        return None


def catalogue_apps_are_reachabable(temp_path: Path, juju: jubilant.Juju):
    stdout = juju.ssh("catalogue/0", "cat /web/config.json", container="catalogue")
    cat_conf = json.loads(stdout)
    apps = {app["name"]: app["url"] for app in cat_conf["apps"]}
    tls_context = get_tls_context(temp_path, juju)
    for app, url in apps.items():
        response = urlopen(url, data=None, timeout=2.0, context=tls_context)
        assert response.code == 200, f"{app} was not reachable"

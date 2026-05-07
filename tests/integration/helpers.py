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
        return f"{target_arg} " + var_args

    def plan_json(self, **kwargs) -> dict:
        """Run terraform plan and return the JSON representation."""
        plan_file = os.path.join(self.dir, "tfplan")
        extras = self._args_str(**kwargs)
        plan_cmd = f"{self.tf_cmd} plan -out={plan_file} " + extras
        subprocess.run(shlex.split(plan_cmd), check=True)
        show_cmd = f"{self.tf_cmd} show -json {plan_file}"
        result = subprocess.run(
            shlex.split(show_cmd), check=True, capture_output=True, text=True
        )
        return json.loads(result.stdout)

    def plan_has_changes(self, **kwargs) -> bool:
        """Return True if terraform plan detects pending changes.

        Uses -detailed-exitcode: exit 0 means no changes, exit 2 means changes pending.
        """
        extras = self._args_str(**kwargs)
        plan_cmd = f"{self.tf_cmd} plan -detailed-exitcode " + extras
        result = subprocess.run(shlex.split(plan_cmd))
        if result.returncode == 0:
            return False
        if result.returncode == 2:
            return True
        # Exit code 1 means error
        raise subprocess.CalledProcessError(result.returncode, plan_cmd)

    def apps_to_replace(self, destroys: List[str], **kwargs):
        plan = self.plan_json(**kwargs)
        destroy_plan_apps = [
            rc["address"].split(".")[-1]
            for rc in plan.get("resource_changes", [])
            if "delete" in rc["change"]["actions"]
            and rc.get("type", "") == "juju_application"
        ]
        assert set(destroys) == set(destroy_plan_apps), (
            f"Expected destroys: {destroys}, got: {destroy_plan_apps}"
        )

    def apply(self, target: Optional[str] = None, **kwargs):
        extras = self._args_str(target, **kwargs)
        cmd_str = f"{self.tf_cmd} apply -auto-approve " + extras
        subprocess.run(shlex.split(cmd_str), check=True)

    def destroy(self, **kwargs):
        extras = self._args_str(**kwargs)
        cmd_str = f"{self.tf_cmd} destroy -auto-approve " + extras
        subprocess.run(shlex.split(cmd_str), check=True)


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

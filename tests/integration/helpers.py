import os
import shlex
import shutil
import subprocess
from typing import List, Optional

import jubilant


class TfDirManager:
    def __init__(self, base_tmpdir):
        self.base: str = str(base_tmpdir)
        self.dir: str = ""
        self.tf_cmd = f"terraform -chdir={self.dir}"

    def init(self, tf_file: str):
        """Initialize a Terraform module in a subdirectory."""
        tf_dir = os.path.join(self.base, "terraform")
        os.makedirs(tf_dir, exist_ok=True)
        shutil.copy(tf_file, os.path.join(tf_dir, "main.tf"))
        subprocess.run(shlex.split(f"{self.tf_cmd} init -upgrade"), check=True)
        self.dir = tf_dir

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


def wait_for_active_idle_without_error(jujus: List[jubilant.Juju]):
    for juju in jujus:
        print(f"\nwaiting for the model ({juju.model}) to settle ...\n")
        juju.wait(jubilant.all_active, delay=5, timeout=60 * 10)
        juju.wait(
            jubilant.all_active, delay=5, timeout=60 * 10, error=jubilant.any_error
        )
        juju.wait(
            jubilant.all_agents_idle,
            delay=5,
            timeout=60 * 10,
            error=jubilant.any_error,
        )

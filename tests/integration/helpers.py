import os
import shlex
import shutil
import subprocess
from contextlib import contextmanager
from typing import List, Optional

import jubilant


@contextmanager
def chdir(path):
    old = os.getcwd()
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(old)


class TfDirManager:
    def __init__(self, base_tmpdir):
        self.base: str = str(base_tmpdir)
        self.dir: str = ""

    def init(self, tf_file: str):
        """Initialize a Terraform module in a subdirectory."""
        tf_dir = os.path.join(self.base, "terraform")
        os.makedirs(tf_dir, exist_ok=True)
        shutil.copy(tf_file, os.path.join(tf_dir, "main.tf"))

        with chdir(tf_dir):
            subprocess.run(shlex.split("terraform init -upgrade"), check=True)

        self.dir = tf_dir

    @staticmethod
    def _args_str(target: Optional[str] = None, **kwargs) -> str:
        target_arg = f"-target module.{target}" if target else ""
        var_args = " ".join(f"-var {k}={v}" for k, v in kwargs.items())
        return "-auto-approve " + f"{target_arg} " + var_args

    def apply(self, target: Optional[str] = None, **kwargs):
        cmd_str = "terraform apply " + self._args_str(target, **kwargs)
        with chdir(self.dir):
            subprocess.run(shlex.split(cmd_str), check=True)

    def destroy(self, **kwargs):
        cmd_str = "terraform destroy " + self._args_str(None, **kwargs)
        with chdir(self.dir):
            subprocess.run(shlex.split(cmd_str), check=True)


def wait_for_active_idle_without_error(jujus: List[jubilant.Juju], timeout: int = 600):
    for juju in jujus:
        print(f"\nwaiting for the model ({juju.model}) to settle ...\n")
        juju.wait(jubilant.all_active, delay=5, timeout=timeout)
        juju.wait(jubilant.all_active, delay=5, timeout=60, error=jubilant.any_error)
        # juju.wait(jubilant.all_agents_idle, delay=5, timeout=60, error=jubilant.any_error)

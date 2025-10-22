import os
import shlex
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Optional

import jubilant
from jinja2 import Template


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


def render_bundle(
    template: Path, output: Path, variables: Optional[Dict[str, str]] = None
):
    """The main function for rendering the bundle template."""
    if variables is None:
        variables = {}
    breakpoint()
    with open(template) as t:
        jinja_template = Template(t.read(), autoescape=True)

    # print(jinja_template.render(**variables))
    with open(output, "wt") as o:
        # Type-ignore because pyright complains:
        # Argument 1 to "dump" of "TemplateStream" has
        # incompatible type "TextIOWrapper"; expected "Union[str, IO[bytes]]"
        jinja_template.stream(**variables).dump(o)  # type: ignore[arg-type]

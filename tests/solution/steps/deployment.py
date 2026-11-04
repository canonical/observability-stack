"""Steps about the deployment itself: which model, and whether it is healthy."""

import os
import subprocess

import jubilant
import pytest
from helpers import (
    _MODEL_ENV_VAR,
    TfDirManager,
    deployment_mode,
    dump_debug_state,
    mode_options,
    terraform_dir,
    terraform_output,
    wait_for_active_idle,
)
from pytest_bdd import given, then


@pytest.fixture(scope="module")
def _terraform_applied(request) -> None:
    """Apply the solution's Terraform wrapper for this test module.

    No-op when SOLUTION_MODEL points at an already-deployed model. Not torn
    down afterwards (see README.md).
    """
    if _MODEL_ENV_VAR in os.environ:
        return

    options = mode_options(request)
    internal_tls = options["internal_tls"]
    external_ca = options["external_ca"]
    ingress = options["ingress"]

    tf_dir = terraform_dir(request)
    solution = tf_dir.parent.name
    repo_root = tf_dir.parents[3]

    var_files = (
        [str(repo_root / "terraform" / solution / "presets" / "no-ingress.tfvars")]
        if ingress == "false"
        else []
    )

    tf_vars = {}
    if internal_tls:
        tf_vars["internal_tls"] = internal_tls
    if external_ca:
        tf_vars["external_ca"] = external_ca

    tf = TfDirManager(dir=str(tf_dir))
    tf.init()
    # Apply is idempotent, so retry once to get past transient errors.
    attempts = 2
    for attempt in range(1, attempts + 1):
        try:
            tf.apply(var_files=var_files, **tf_vars)
            return
        except subprocess.CalledProcessError:
            dump_debug_state(f"terraform apply failed (attempt {attempt}/{attempts})")
            if attempt == attempts:
                raise


@given("the solution has been deployed", target_fixture="juju")
def the_solution_has_been_deployed(request, _terraform_applied) -> jubilant.Juju:
    model_name = os.environ.get(_MODEL_ENV_VAR)
    if model_name is None:
        model_name = terraform_output(terraform_dir(request))["model_name"]["value"]
    return jubilant.Juju(model=model_name)


@given("the model is healthy")
@then("the model is healthy")
def the_model_is_healthy(request, juju: jubilant.Juju):
    """Every application active and every agent idle, in the solution model
    and, when present, the external-CA model."""
    wait_for_active_idle(juju)

    ca_model_name = deployment_mode(request)["ca_model_name"]
    if ca_model_name is not None:
        wait_for_active_idle(jubilant.Juju(model=ca_model_name))

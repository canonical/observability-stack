"""Steps about the deployment itself: which model, and whether it is healthy."""

import os
from typing import NamedTuple

import jubilant
import pytest
from helpers import TfDirManager, terraform_dir, terraform_output, wait_for_active_idle
from pytest_bdd import given, then

# Points the "given" step at an already-deployed model instead of applying
# the Terraform wrapper ourselves (see README.md).
_MODEL_ENV_VAR = "SOLUTION_MODEL"


class _ModeVars(NamedTuple):
    internal_tls: str
    external_ca: str


# Keyed on every value --tls-mode's choices= allows (see conftest.py). "" (the
# wrapper's own default) carries tls_internal's values explicitly rather than
# omitting the -vars: passing a value equal to a Terraform variable's own
# default has the same effect as leaving it unset, so every mode can be
# applied the same way below, with no silently-defaulting lookup.
_TLS_MODES = {
    "": _ModeVars(internal_tls="true", external_ca="false"),
    "tls_none": _ModeVars(internal_tls="false", external_ca="false"),
    "tls_internal": _ModeVars(internal_tls="true", external_ca="false"),
    "tls_external": _ModeVars(internal_tls="false", external_ca="true"),
    "tls_full": _ModeVars(internal_tls="true", external_ca="true"),
}


@pytest.fixture(scope="module")
def _terraform_applied(request) -> None:
    """Apply the solution's Terraform wrapper for this test module.

    No-op when SOLUTION_MODEL points at an already-deployed model. Not torn
    down afterwards (see README.md).
    """
    if _MODEL_ENV_VAR in os.environ:
        return

    tls_mode = request.config.getoption("--tls-mode")
    ingress_mode = request.config.getoption("--ingress-mode")
    if tls_mode in ("tls_full", "tls_external") and ingress_mode == "no_ingress":
        pytest.fail(
            f"--tls-mode={tls_mode} with --ingress-mode=no_ingress would deploy "
            "the external-CA model and offer for nothing: the product module "
            "silently no-ops the external-CA wiring without ingress."
        )

    tf_dir = terraform_dir(request)
    solution = tf_dir.parent.name
    repo_root = tf_dir.parents[3]

    var_files = (
        [str(repo_root / "terraform" / solution / "presets" / "no-ingress.tfvars")]
        if ingress_mode == "no_ingress"
        else []
    )

    tf = TfDirManager(dir=str(tf_dir))
    tf.init()
    mode_vars = _TLS_MODES[tls_mode]
    tf.apply(
        var_files=var_files,
        internal_tls=mode_vars.internal_tls,
        external_ca=mode_vars.external_ca,
    )


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

    ca_model_output = terraform_output(terraform_dir(request)).get("ca_model_name", {})
    ca_model_name = ca_model_output.get("value")
    if ca_model_name is not None:
        wait_for_active_idle(jubilant.Juju(model=ca_model_name))

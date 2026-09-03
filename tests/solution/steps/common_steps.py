"""Step definitions shared across feature files (deploy, wait, health checks)."""

import os
from pathlib import Path

import jubilant
from helpers import terraform_output, wait_for_active_idle
from pytest_bdd import given, then, when

# Points the "given" step at an already-deployed model instead of
# discovering one from `terraform output` (see README.md).
_MODEL_ENV_VAR = "SOLUTION_MODEL"


@given("the solution has been deployed", target_fixture="juju")
def the_solution_has_been_deployed(request) -> jubilant.Juju:
    model_name = os.environ.get(_MODEL_ENV_VAR)
    if model_name is None:
        terraform_dir = Path(request.module.__file__).parent / "terraform"
        model_name = terraform_output(terraform_dir)["model_name"]["value"]
    return jubilant.Juju(model=model_name)


@when("no action is done")
def no_action_is_done():
    """No-op step: some scenarios (e.g. the smoke test) have no action to perform."""


@then("the model settles into a healthy state")
def the_model_settles_into_a_healthy_state(juju: jubilant.Juju):
    wait_for_active_idle(juju)

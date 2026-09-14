"""Steps about the deployment itself: which model, and whether it is healthy.

The deployment is carried out externally (Terraform, or an outer suite), so
these steps discover and inspect a model rather than create one.
"""

import os
from pathlib import Path

import jubilant
from helpers import terraform_output, wait_for_active_idle
from pytest_bdd import given, then

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


@given("the model is healthy")
@then("the model is healthy")
def the_model_is_healthy(juju: jubilant.Juju):
    """Every application active and every agent idle, held stably.

    Registered as both `given` and `then`: it is the precondition every other
    feature builds on, and the assertion the smoke test exists to make.
    """
    wait_for_active_idle(juju)

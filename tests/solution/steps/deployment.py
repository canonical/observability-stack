"""Steps about the deployment itself: which model, and whether it is healthy."""

import os

import jubilant
from helpers import (
    _MODEL_ENV_VAR,
    deployment_mode,
    terraform_dir,
    terraform_output,
    wait_for_active_idle,
)
from pytest_bdd import given, then


@given("the solution has been deployed", target_fixture="juju")
def the_solution_has_been_deployed(request) -> jubilant.Juju:
    """The solution's model: SOLUTION_MODEL if set, else the one `just solution test` deployed."""
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

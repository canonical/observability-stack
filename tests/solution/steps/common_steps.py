"""Step definitions shared across feature files (deploy, wait, health checks)."""

import jubilant
from helpers import wait_for_active_idle
from pytest_bdd import given, then, when


@given("the solution has been deployed")
def the_solution_has_been_deployed(juju: jubilant.Juju) -> None:
    """The model comes from the `juju` fixture in conftest.py."""


@when("no action is done")
def no_action_is_done():
    """No-op step: some scenarios (e.g. the smoke test) have no action to perform."""


@then("the model settles into a healthy state")
def the_model_settles_into_a_healthy_state(juju: jubilant.Juju):
    wait_for_active_idle(juju)

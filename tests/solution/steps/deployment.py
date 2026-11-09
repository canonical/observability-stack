"""Steps about the deployment itself: its model, its health and the mode it was deployed in.

`just solution test` deploys the solution, so pytest deploys nothing: the `Given` steps only
state what the deployment is like, and skip the scenario when it isn't.
"""

import jubilant
import pytest
from pytest_bdd import given, parsers, then

from helpers import Mode


def wait_for_active_idle(juju: jubilant.Juju, timeout: int = 60 * 45) -> None:
    """Wait for every application to be active and every agent to be idle."""
    juju.wait(
        lambda status: jubilant.all_active(status) and jubilant.all_agents_idle(status),
        delay=10,
        timeout=timeout,
    )


@pytest.fixture(scope="module")
def settled(juju: jubilant.Juju, mode: Mode) -> None:
    """Wait for the solution's model and, if any, the external CA's to settle.

    Module-scoped, so the wait happens once: when a model never settles, pytest raises
    the same error for the scenarios after the first instead of waiting out the timeout for each.
    """
    wait_for_active_idle(juju)
    if mode.ca_model_name:
        wait_for_active_idle(jubilant.Juju(model=mode.ca_model_name))


@given("the solution has been deployed")
def the_solution_has_been_deployed(juju: jubilant.Juju):
    assert juju.status().apps, (
        f"model '{juju.model}' has no applications; `just solution test` deploys the solution"
    )


@given("the model is healthy")
@then("the model is healthy")
def the_model_is_healthy(settled: None):
    """Every application active and every agent idle."""


@given("the solution is deployed with internal TLS")
def with_internal_tls(mode: Mode):
    if not mode.internal_tls:
        pytest.skip("the solution is deployed without internal TLS")


@given("the solution is deployed without internal TLS")
def without_internal_tls(mode: Mode):
    if mode.internal_tls:
        pytest.skip("the solution is deployed with internal TLS")


@given("the solution is deployed with an external CA")
def with_external_ca(mode: Mode):
    if not mode.external_ca:
        pytest.skip("the solution is deployed without an external CA")


@given("the solution is deployed with an ingress")
def with_ingress(juju: jubilant.Juju, mode: Mode):
    if not mode.traefik:
        pytest.skip("the solution is deployed without an ingress")
    assert "traefik" in juju.status().apps, (
        "Traefik should be deployed but isn't in the model"
    )


@given(parsers.parse("{component} is exposed through the ingress"))
def exposed_through_ingress(mode: Mode, component: str):
    if not mode.ingress.get(component):
        pytest.skip(f"{component} has no ingress in this deployment")

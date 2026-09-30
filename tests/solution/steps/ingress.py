"""Steps about ingress: whether a reverse proxy fronts the deployment at all.

The `ingress` mode is a blanket on/off switch for every component (see
terraform/cos-lite/presets/no-ingress.tfvars and each solution's `terraform/`
wrapper), so its effect is visible directly on the model: with ingress off, no
reverse-proxy charm gets deployed at all, rather than just a set of skipped
relations.
"""

import jubilant
from pytest_bdd import parsers, then


@then(parsers.parse('the "{application}" application is deployed'))
def application_is_deployed(juju: jubilant.Juju, application: str):
    assert application in juju.status().apps, f"'{application}' is not deployed"


@then(parsers.parse('the "{application}" application is not deployed'))
def application_is_not_deployed(juju: jubilant.Juju, application: str):
    assert application not in juju.status().apps, f"'{application}' is unexpectedly deployed"

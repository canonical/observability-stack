"""Steps about ingress: asks the deployment itself whether it's enabled.

No mode tag or env var to keep in sync with what got deployed -- the
wrapper's own `ingress_enabled` output is the single source of truth. Ingress
is a blanket on/off switch for every component (see
terraform/cos-lite/presets/no-ingress.tfvars and the wrapper's own `ingress`
variable), so its effect is visible directly on the model: with ingress off,
no reverse-proxy charm (Traefik) gets deployed at all, rather than just a set
of skipped relations.
"""

import jubilant
from helpers import terraform_dir, terraform_output
from pytest_bdd import parsers, then


@then(parsers.parse('the "{application}" application is deployed iff ingress is enabled'))
def application_is_deployed_iff_ingress_enabled(juju: jubilant.Juju, request, application: str):
    ingress_enabled = terraform_output(terraform_dir(request))["ingress_enabled"]["value"]
    deployed = application in juju.status().apps
    assert deployed == ingress_enabled, (
        f"'{application}' deployed={deployed}, but ingress_enabled={ingress_enabled}"
    )

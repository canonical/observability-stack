"""Steps about TLS: introspects the wrapper's own Terraform outputs instead of a mode tag."""

import json
from urllib.parse import urlparse
from urllib.request import urlopen

import jubilant
from helpers import _PORTS, get_tls_context, terraform_dir, terraform_output, unit_url
from pytest_bdd import parsers, then


@then(
    parsers.parse("{component} serves traffic using the deployment's internal TLS mode")
)
def component_serves_traffic_using_internal_tls_mode(
    juju: jubilant.Juju, request, component: str
):
    internal_tls = terraform_output(terraform_dir(request))["internal_tls"]["value"]
    expected = "https" if internal_tls else "http"
    actual = urlparse(unit_url(juju, component, _PORTS[component])).scheme
    assert actual == expected, (
        f"{component} is served over {actual}, but internal_tls={internal_tls} implies {expected}"
    )


@then(
    parsers.parse(
        "{component}'s certificate is trusted by the deployment's configured CA"
    )
)
def components_certificate_is_trusted_by_configured_ca(
    juju: jubilant.Juju, request, component: str
):
    output = terraform_output(terraform_dir(request))
    if not output["tls_termination"]["value"]:
        # tls_none/tls_internal: nothing extra to check, covered by the step above.
        return

    ca_model_name = output["ca_model_name"]["value"]
    ctx = get_tls_context(
        jubilant.Juju(model=ca_model_name), "self-signed-certificates"
    )

    # The external CA only terminates TLS at Traefik's own ingress-facing
    # certificate, not at each component's own unit, so the check goes
    # through the ingressed URL rather than unit_url.
    proxied_endpoints = json.loads(
        juju.run("traefik/leader", "show-proxied-endpoints").results[
            "proxied-endpoints"
        ]
    )
    url = proxied_endpoints[component]["url"]
    with urlopen(url, timeout=30, context=ctx) as response:
        assert response.status == 200, f"{component} was not reachable through Traefik"

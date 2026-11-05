"""Steps about TLS: checks the model against `deployment_mode` instead of a mode tag."""

from urllib.parse import urlparse

import jubilant
from helpers import (
    _PORTS,
    deployment_mode,
    get_tls_context,
    ingressed_url,
    tls_handshake_error,
    unit_url,
)
from pytest_bdd import parsers, then

_INTERNAL_CA_APP = "ca"  # the product modules' default
_HTTPS_PORT = 443  # for an https URL that doesn't name a port


@then(
    parsers.parse("{component} serves traffic using the deployment's internal TLS mode")
)
def component_serves_traffic_using_internal_tls_mode(
    juju: jubilant.Juju, request, component: str
):
    internal_tls = deployment_mode(request)["internal_tls"]
    expected = "https" if internal_tls else "http"
    actual = urlparse(unit_url(juju, component, _PORTS[component])).scheme
    assert actual == expected, (
        f"{component} is served over {actual}, but internal_tls={internal_tls} implies {expected}"
    )


@then(
    parsers.parse(
        "{component}'s certificate is trusted by the deployment's internal CA if any"
    )
)
def components_certificate_is_trusted_by_internal_ca(
    juju: jubilant.Juju, request, component: str
):
    if not deployment_mode(request)["internal_tls"]:
        return

    ctx = get_tls_context(juju, _INTERNAL_CA_APP)
    assert ctx is not None, f"internal CA app '{_INTERNAL_CA_APP}' is not deployed"

    # Cluster DNS isn't resolvable from the runner: connect by IP, verify the FQDN.
    for unit_name, unit in juju.status().apps[component].units.items():
        fqdn = (
            f"{unit_name.replace('/', '-')}.{component}-endpoints"
            f".{juju.model}.svc.cluster.local"
        )
        error = tls_handshake_error(unit.address, _PORTS[component], fqdn, ctx)
        assert error is None, (
            f"{unit_name}'s certificate isn't valid for {fqdn} under the internal CA: {error}"
        )


@then(
    parsers.parse(
        "{component}'s certificate is trusted by the deployment's external CA if any"
    )
)
def components_certificate_is_trusted_by_external_ca(
    juju: jubilant.Juju, request, component: str
):
    mode = deployment_mode(request)
    if not mode["tls_termination"]:
        return

    # The external CA only signs Traefik's certificate, so check the ingressed URL.
    # (mode["ingress"] is None with SOLUTION_MODEL, which can't get here yet.)
    if not mode["ingress"].get(component):
        return
    url = ingressed_url(juju, component)
    assert url is not None, (
        f"{component} should be ingressed in this mode, but Traefik has no route for it"
    )

    ca_model_name = mode["ca_model_name"]
    ctx = get_tls_context(
        jubilant.Juju(model=ca_model_name), "self-signed-certificates"
    )
    assert ctx is not None, f"external CA isn't deployed in model '{ca_model_name}'"
    parsed = urlparse(url)
    error = tls_handshake_error(
        parsed.hostname, parsed.port or _HTTPS_PORT, parsed.hostname, ctx
    )
    assert error is None, (
        f"{component}'s ingress certificate isn't trusted by the external CA: {error}"
    )

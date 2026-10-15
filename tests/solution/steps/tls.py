"""Steps about TLS: introspects the wrapper's own Terraform outputs instead of a mode tag."""

import socket
import ssl
from urllib.parse import urlparse

import jubilant
from helpers import (
    _PORTS,
    get_tls_context,
    ingressed_url,
    terraform_dir,
    terraform_output,
    unit_url,
)
from pytest_bdd import parsers, then

_INTERNAL_CA_APP = "ca"  # the product modules' default


def _tls_handshake(
    address: str, port: int, server_hostname: str, ctx: ssl.SSLContext
) -> None:
    """Complete a TLS handshake, verifying the peer's certificate against `ctx`."""
    with (
        socket.create_connection((address, port), timeout=30) as sock,
        ctx.wrap_socket(sock, server_hostname=server_hostname),
    ):
        pass


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
        "{component}'s certificate is trusted by the deployment's internal CA"
    )
)
def components_certificate_is_trusted_by_internal_ca(
    juju: jubilant.Juju, request, component: str
):
    if not terraform_output(terraform_dir(request))["internal_tls"]["value"]:
        return

    ctx = get_tls_context(juju, _INTERNAL_CA_APP)
    assert ctx is not None, f"internal CA app '{_INTERNAL_CA_APP}' is not deployed"

    # Cluster DNS isn't resolvable from the runner: connect by IP, verify the FQDN.
    for unit_name, unit in juju.status().apps[component].units.items():
        fqdn = (
            f"{unit_name.replace('/', '-')}.{component}-endpoints"
            f".{juju.model}.svc.cluster.local"
        )
        try:
            _tls_handshake(unit.address, _PORTS[component], fqdn, ctx)
        except ssl.SSLError as exc:
            raise AssertionError(
                f"{unit_name}'s certificate isn't valid for {fqdn} under the internal CA: {exc}"
            ) from exc


@then(
    parsers.parse(
        "{component}'s certificate is trusted by the deployment's external CA"
    )
)
def components_certificate_is_trusted_by_external_ca(
    juju: jubilant.Juju, request, component: str
):
    output = terraform_output(terraform_dir(request))
    if not output["tls_termination"]["value"]:
        return

    # The external CA only signs Traefik's certificate, so check the ingressed URL.
    url = ingressed_url(juju, request, component, _PORTS[component])
    if url is None:
        return

    ca_model_name = output["ca_model_name"]["value"]
    ctx = get_tls_context(
        jubilant.Juju(model=ca_model_name), "self-signed-certificates"
    )
    assert ctx is not None, f"external CA isn't deployed in model '{ca_model_name}'"
    parsed = urlparse(url)
    try:
        _tls_handshake(parsed.hostname, parsed.port or 443, parsed.hostname, ctx)
    except ssl.SSLError as exc:
        raise AssertionError(
            f"{component}'s ingress certificate isn't trusted by the external CA: {exc}"
        ) from exc

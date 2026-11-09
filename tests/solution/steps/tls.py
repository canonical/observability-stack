"""Steps about TLS: the certificates the components serve, and the CAs that signed them."""

import ssl
from urllib.parse import urlparse

import jubilant
import pytest
from pytest_bdd import parsers, then

from helpers import (
    PORTS,
    Mode,
    ca_context,
    ingressed_url,
    tls_handshake_error,
    unit_fqdn,
    unit_url,
)

# The apps the CAs run as: the product modules' default for the internal one, and the
# self-signed-certificates module's for the external one in its own model.
INTERNAL_CA_APP = "ca"
EXTERNAL_CA_APP = "self-signed-certificates"

# The port of an https URL that doesn't name one.
HTTPS_PORT = 443


@pytest.fixture(scope="module")
def internal_ca(juju: jubilant.Juju) -> ssl.SSLContext:
    return ca_context(juju, INTERNAL_CA_APP)


@pytest.fixture(scope="module")
def external_ca(mode: Mode) -> ssl.SSLContext:
    return ca_context(jubilant.Juju(model=mode.ca_model_name), EXTERNAL_CA_APP)


@then(
    parsers.parse(
        "{component}'s units serve certificates for their in-cluster FQDN, "
        "signed by the internal CA"
    )
)
def units_serve_certificates_signed_by_internal_ca(
    juju: jubilant.Juju, internal_ca: ssl.SSLContext, component: str
):
    # Cluster DNS isn't resolvable from the runner: connect by IP, verify the FQDN.
    for unit_name, unit in juju.status().apps[component].units.items():
        fqdn = unit_fqdn(juju, unit_name)
        error = tls_handshake_error(unit.address, PORTS[component], fqdn, internal_ca)
        assert error is None, (
            f"{unit_name}'s certificate isn't valid for {fqdn} under the internal CA: {error}"
        )


@then(parsers.parse("{component} serves plain HTTP"))
def serves_plain_http(juju: jubilant.Juju, component: str):
    scheme = urlparse(unit_url(juju, component)).scheme
    assert scheme == "http", f"{component} is served over {scheme}"


@then(parsers.parse("{component}'s ingress certificate is signed by the external CA"))
def ingress_certificate_signed_by_external_ca(
    proxied_endpoints: dict, external_ca: ssl.SSLContext, component: str
):
    url = ingressed_url(proxied_endpoints, component)
    assert url is not None, f"Traefik has no route for {component}"
    parsed = urlparse(url)
    error = tls_handshake_error(
        parsed.hostname, parsed.port or HTTPS_PORT, parsed.hostname, external_ca
    )
    assert error is None, (
        f"{component}'s ingress certificate isn't signed by the external CA: {error}"
    )

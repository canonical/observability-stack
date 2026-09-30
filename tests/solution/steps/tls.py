"""Steps about internal TLS: asks the deployment itself which mode is live.

No mode tag or env var to keep in sync with what got deployed -- the
wrapper's own `internal_tls` output is the single source of truth.
"""

from urllib.parse import urlparse

import jubilant
from helpers import terraform_dir, terraform_output, unit_url
from pytest_bdd import parsers, then

# Mirrors the ports clients.py's fixtures use.
_PORTS = {
    "alertmanager": 9093,
    "grafana": 3000,
    "loki": 3100,
    "mimir": 8080,
    "prometheus": 9090,
    "tempo": 3200,
}


@then(
    parsers.parse(
        'the "{application}" application is served over the scheme internal TLS implies'
    )
)
def application_is_served_over_scheme_internal_tls_implies(
    juju: jubilant.Juju, request, application: str
):
    internal_tls = terraform_output(terraform_dir(request))["internal_tls"]["value"]
    expected = "https" if internal_tls else "http"
    actual = urlparse(unit_url(juju, application, _PORTS[application])).scheme
    assert actual == expected, (
        f"{application} is served over {actual}, but internal_tls={internal_tls} implies {expected}"
    )

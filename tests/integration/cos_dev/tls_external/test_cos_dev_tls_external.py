"""There are 2 sections of the COS Dev deployment (internal and external) which can implement TLS
communication. This python test file deploys COS Dev with external TLS, and without internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import (
    catalogue_apps_are_reachable,
    get_tls_context,
    no_errors_in_otelcol_logs,
    wait_for_active_idle_without_error,
    xfail_otelcol_logs,
)

TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"


def test_deploy(tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju):
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)
    wait_for_active_idle_without_error([ca_model, cos_model])
    tls_ctx = get_tls_context(tmp_path, ca_model, "self-signed-certificates")
    catalogue_apps_are_reachable(cos_model, tls_ctx)


@xfail_otelcol_logs
def test_no_errors_in_otelcol_logs_dev(cos_model: jubilant.Juju):
    no_errors_in_otelcol_logs(cos_model)

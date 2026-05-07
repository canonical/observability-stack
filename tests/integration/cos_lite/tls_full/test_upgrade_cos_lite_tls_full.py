"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with external and internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import (
    catalogue_apps_are_reachable,
    get_tls_context,
    no_errors_in_otelcol_logs,
    wait_for_active_idle_without_error,
)

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"
TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"


def test_deploy_from_track_2(
    tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed from track 2
    tf_manager.init(TRACK_2_TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)
    wait_for_active_idle_without_error([ca_model, cos_model], timeout=60 * 60)
    tls_ctx = get_tls_context(tmp_path, ca_model, "self-signed-certificates")
    catalogue_apps_are_reachable(cos_model, tls_ctx)


def test_deploy_to_track_dev(
    tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # WHEN upgraded to track dev
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)

    # THEN the model is upgraded and is healthy
    wait_for_active_idle_without_error([ca_model, cos_model])
    tls_ctx = get_tls_context(tmp_path, ca_model, "self-signed-certificates")
    catalogue_apps_are_reachable(cos_model, tls_ctx)
    no_errors_in_otelcol_logs(cos_model)

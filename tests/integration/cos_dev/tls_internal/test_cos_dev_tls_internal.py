"""Integration test for COS Dev deployed with internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import (
    catalogue_apps_are_reachable,
    no_errors_in_otelcol_logs,
    wait_for_active_idle_without_error,
    xfail_otelcol_logs,
)

TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"


def test_deploy(tf_manager, cos_model: jubilant.Juju):
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    wait_for_active_idle_without_error([cos_model])
    catalogue_apps_are_reachable(cos_model)


@xfail_otelcol_logs
def test_no_errors_in_otelcol_logs_dev(cos_model: jubilant.Juju):
    no_errors_in_otelcol_logs(cos_model)

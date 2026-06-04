"""Integration test for COS Dev deployed without TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import generic_assertions, no_errors_in_otelcol_logs

TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"


def test_deploy(tf_manager, cos_model: jubilant.Juju):
    # GIVEN a module deployed from track dev
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    generic_assertions(cos_model)
    no_errors_in_otelcol_logs(cos_model)

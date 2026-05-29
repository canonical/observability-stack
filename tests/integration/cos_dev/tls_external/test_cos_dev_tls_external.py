"""There are 2 sections of the COS Dev deployment (internal and external) which can implement TLS
communication. This python test file deploys COS Dev with external TLS, and without internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import generic_assertions, no_errors_in_otelcol_logs

TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"


def test_deploy(
    tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed from track dev
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)
    generic_assertions(cos_model, ca_model, tmp_path)
    no_errors_in_otelcol_logs(cos_model)

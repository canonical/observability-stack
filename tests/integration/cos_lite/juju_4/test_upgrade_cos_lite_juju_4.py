"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with external and internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import generic_assertions

TF_FILE = Path(__file__).parent.parent.resolve() / "tls_full/track-3.0.tf"


def test_deploy_from_track(
    tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed with full TLS configuration, providing the most coverage of the TLS
    # configuration options
    tf_manager.init(TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)
    generic_assertions(cos_model, ca_model, tmp_path)

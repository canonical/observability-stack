"""Test the deployment of COS in full TLS mode for the current track.

Any pytest file within this parent directory will be run against Juju v4."""

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

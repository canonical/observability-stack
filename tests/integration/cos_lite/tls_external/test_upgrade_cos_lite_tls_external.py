"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with external TLS, and without internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import generic_assertions

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"
TRACK_3_TF_FILE = Path(__file__).parent.resolve() / "track-3.0.tf"
TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"


def test_deploy_from_track_2(
    tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed from track 2
    tf_manager.init(TRACK_2_TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)
    generic_assertions(cos_model, ca_model, tmp_path)


def test_deploy_to_track_3(
    tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # WHEN upgraded to track 3.0
    tf_manager.init(TRACK_3_TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)

    # THEN the model is upgraded and is healthy
    generic_assertions(cos_model, ca_model, tmp_path)


def test_deploy_to_track_dev(
    tmp_path, tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # WHEN upgraded to track dev
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)

    # THEN the model is upgraded and is healthy
    generic_assertions(cos_model, ca_model, tmp_path)

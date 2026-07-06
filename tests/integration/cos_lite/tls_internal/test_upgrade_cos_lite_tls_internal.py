"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with internal TLS, and without external TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import generic_assertions

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"
TRACK_3_TF_FILE = Path(__file__).parent.resolve() / "track-3.0.tf"


def test_deploy_from_track(tf_manager, cos_model: jubilant.Juju):
    # GIVEN a module deployed from the previous track
    tf_manager.init(TRACK_2_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    generic_assertions(cos_model)


def test_deploy_to_track(tf_manager, cos_model: jubilant.Juju):
    # WHEN upgraded to the next track
    tf_manager.init(TRACK_3_TF_FILE)
    tf_manager.apply(model=cos_model.model)

    # THEN the model is upgraded and is healthy
    generic_assertions(cos_model)

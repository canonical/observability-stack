"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS without external and internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

import jubilant
from helpers import wait_for_active_idle_without_error

TRACK_1_TF_FILE = Path(__file__).parent.resolve() / "track-1.tf"
TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"


def test_deploy_from_track(tf_manager, cos_model: jubilant.Juju):
    # GIVEN a module deployed from track n-1
    tf_manager.init(TRACK_1_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    wait_for_active_idle_without_error([cos_model])


def test_deploy_to_track(tf_manager, cos_model: jubilant.Juju):
    # WHEN upgraded to track n
    tf_manager.init(TRACK_2_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    # THEN the model is upgraded and is active/idle
    wait_for_active_idle_without_error([cos_model])

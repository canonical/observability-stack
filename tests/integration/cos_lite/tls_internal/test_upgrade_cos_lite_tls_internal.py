"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with internal TLS, and without external TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

from helpers import (
    catalogue_apps_are_reachable,
    wait_for_active_idle_without_error,
)

import jubilant

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"


def test_deploy_from_track(tf_manager, cos_model: jubilant.Juju):
    # GIVEN a module deployed from track n-1
    tf_manager.init(TRACK_2_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    wait_for_active_idle_without_error([cos_model])
    catalogue_apps_are_reachable(cos_model)

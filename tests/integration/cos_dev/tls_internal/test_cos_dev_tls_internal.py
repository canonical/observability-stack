"""Integration test for COS Dev deployed with internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

from pathlib import Path

from helpers import catalogue_apps_are_reachable, wait_for_active_idle_without_error

import jubilant

TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"


def test_deploy(tf_manager, cos_model: jubilant.Juju):
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(model=cos_model.model)
    wait_for_active_idle_without_error([cos_model])
    catalogue_apps_are_reachable(cos_model)

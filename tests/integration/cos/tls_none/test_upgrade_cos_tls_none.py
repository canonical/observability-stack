"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS without external and internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

import os
from pathlib import Path

import jubilant
import pytest
from helpers import wait_for_active_idle_without_error

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"
S3_ENDPOINT = {
    "s3_endpoint": os.getenv("S3_ENDPOINT"),
    "s3_secret_key": os.getenv("S3_SECRET_KEY"),
    "s3_access_key": os.getenv("S3_ACCESS_KEY"),
}


def test_envvars():
    assert all(S3_ENDPOINT.values())


@pytest.mark.skip()
@pytest.mark.xfail(
    reason="When host is resource-constrained, model can take too long to settle"
)
def test_deploy_from_track(tf_manager, cos_model: jubilant.Juju):
    # GIVEN a module deployed from track n
    tf_manager.init(TRACK_2_TF_FILE)
    tf_manager.apply(model=cos_model.model, **S3_ENDPOINT)
    wait_for_active_idle_without_error([cos_model], timeout=7200)

"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with internal TLS, and without external TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

import os
from pathlib import Path

from helpers import (
    catalogue_apps_are_reachable,
    refresh_o11y_apps,
    wait_for_active_idle_without_error,
)

import jubilant

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"
TRACK_DEV_TF_FILE = Path(__file__).parent.resolve() / "track-dev.tf"
S3_ENDPOINT = {
    "s3_endpoint": os.getenv("S3_ENDPOINT"),
    "s3_secret_key": os.getenv("S3_SECRET_KEY"),
    "s3_access_key": os.getenv("S3_ACCESS_KEY"),
}


def test_envvars():
    assert all(S3_ENDPOINT.values()), (
        f"export the following env vars (upper case) before running this test: {S3_ENDPOINT.keys()}"
    )


def test_deploy_from_track(tmp_path, tf_manager, cos_model: jubilant.Juju):
    # GIVEN a module deployed from track n
    tf_manager.init(TRACK_2_TF_FILE)
    tf_manager.apply(model=cos_model.model, **S3_ENDPOINT)
    wait_for_active_idle_without_error([cos_model], timeout=5400)
    catalogue_apps_are_reachable(cos_model)


def test_deploy_to_track(tmp_path, tf_manager, cos_model: jubilant.Juju):
    # WHEN upgraded to track n
    tf_manager.init(TRACK_DEV_TF_FILE)
    tf_manager.apply(model=cos_model.model)

    # FIXME: https://github.com/juju/terraform-provider-juju/issues/967
    refresh_o11y_apps(cos_model, channel="dev/edge", base="ubuntu@24.04")

    # THEN the model is upgraded and is active/idle
    wait_for_active_idle_without_error([cos_model])
    catalogue_apps_are_reachable(cos_model)

"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS without external and internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

import os
from pathlib import Path

import jubilant
from helpers import wait_for_active_idle_without_error, render_bundle

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"
TRACK_2_BUNDLE_TEMPLATE = Path(__file__).parent.resolve() / "track-2.yaml.j2"
TRACK_2_RENDERED_BUNDLE = Path(__file__).parent.resolve() / "rendered-track-2.yaml"
S3_ENDPOINT = {
    "s3_endpoint": os.getenv("S3_ENDPOINT"),
    "s3_secret_key": os.getenv("S3_SECRET_KEY"),
    "s3_access_key": os.getenv("S3_ACCESS_KEY"),
}


def test_envvars():
    assert all(S3_ENDPOINT.values())


def test_deploy_from_track(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed from track n
    render_bundle(
        TRACK_2_BUNDLE_TEMPLATE,
        TRACK_2_RENDERED_BUNDLE,
        variables={
            "s3_endpoint": S3_ENDPOINT["s3_endpoint"],
            "ca_model": ca_model.model,
        },
    )
    cos_model.deploy(TRACK_2_RENDERED_BUNDLE, trust=True)
    os.remove(TRACK_2_RENDERED_BUNDLE)
    s3_creds = cos_model.add_secret(
        "s3creds",
        {
            "access-key": S3_ENDPOINT["s3_access_key"],
            "secret-key": S3_ENDPOINT["s3_secret_key"],
        },
    )
    for coordinator in ["loki", "mimir", "tempo"]:
        cos_model.grant_secret(s3_creds, f"{coordinator}-s3-integrator")
        cos_model.config(f"{coordinator}-s3-integrator", {"credentials": s3_creds})

    wait_for_active_idle_without_error([cos_model], timeout=7200)

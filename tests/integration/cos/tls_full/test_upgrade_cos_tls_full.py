"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with external and internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

import os
from pathlib import Path

import jubilant
import pytest
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


@pytest.mark.skip()
@pytest.mark.xfail(
    reason="When host is resource-constrained, model can take too long to settle"
)
def test_deploy_from_track(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed from track n
    tf_manager.init(TRACK_2_TF_FILE)
    # NOTE: "Terraform cannot predict how many instances will be created. To work around this,
    # use the -target argument to first apply only the resources that the count depends on."
    tf_manager.apply(
        target="ssc",
        ca_model=ca_model.model,
        cos_model=cos_model.model,
        **S3_ENDPOINT,
    )
    tf_manager.apply(
        ca_model=ca_model.model,
        cos_model=cos_model.model,
        **S3_ENDPOINT,
    )
    wait_for_active_idle_without_error([cos_model], timeout=7200)


def test_deploy_bundle_from_track(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed from track n
    tf_manager.init(TRACK_2_TF_FILE)
    # TODO: We can avoid using TF here and use juju-deploy, but then we need to also juju.offer and whatever else the TF mod does for us
    tf_manager.apply(
        "ssc", ca_model=ca_model.model, cos_model=cos_model.model, **S3_ENDPOINT
    )
    render_bundle(
        TRACK_2_BUNDLE_TEMPLATE,
        TRACK_2_RENDERED_BUNDLE,
        variables={"s3_endpoint": os.getenv("S3_ENDPOINT"), "ca_model": ca_model.model},
    )
    breakpoint()
    cos_model.deploy(TRACK_2_RENDERED_BUNDLE, trust=True)
    s3_creds = cos_model.add_secret(
        "s3creds", {"access-key": "access-key", "secret-key": "secret-key"}
    )
    for coordinator in ["loki", "mimir", "tempo"]:
        cos_model.grant_secret(s3_creds, f"{coordinator}-s3-integrator")
        cos_model.config(f"{coordinator}-s3-integrator", {"credentials": s3_creds})

    wait_for_active_idle_without_error([cos_model], timeout=7200)
    # TODO: Place this in a cleanup test?
    os.remove(TRACK_2_RENDERED_BUNDLE)

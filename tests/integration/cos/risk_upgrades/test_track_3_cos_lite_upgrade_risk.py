import os
from pathlib import Path

import jubilant
from helpers import generic_assertions

TF_FILE = Path(__file__).parent.parent.resolve() / "tls_full/track-3.0.tf"
S3_ENDPOINT = {
    "s3_endpoint": os.getenv("S3_ENDPOINT"),
    "s3_secret_key": os.getenv("S3_SECRET_KEY"),
    "s3_access_key": os.getenv("S3_ACCESS_KEY"),
}


def test_envvars():
    assert all(S3_ENDPOINT.values()), (
        f"export the following env vars (upper case) before running this test: {S3_ENDPOINT.keys()}"
    )


def test_deploy_from_stable(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju, tmp_path
):
    # GIVEN a module deployed with a "stable" risk
    tf_manager.init(TF_FILE)
    tf_manager.apply(
        ca_model=ca_model.model, cos_model=cos_model.model, risk="stable", **S3_ENDPOINT
    )
    generic_assertions(cos_model, ca_model, tmp_path)


def test_upgrade_path(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju, tmp_path
):
    # WHEN upgraded to higher risk
    for risk in ["candidate", "beta", "edge"]:
        tf_manager.init(TF_FILE)
        tf_manager.apply(
            ca_model=ca_model.model, cos_model=cos_model.model, risk=risk, **S3_ENDPOINT
        )

        # THEN the model is upgraded and is healthy
        generic_assertions(cos_model, ca_model, tmp_path)

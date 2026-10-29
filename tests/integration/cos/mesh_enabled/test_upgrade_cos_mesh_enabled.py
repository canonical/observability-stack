"""This python test file deploys COS and then enables service mesh."""

import os
from pathlib import Path

import jubilant
from helpers import (
    generic_assertions,
    no_errors_in_otelcol_logs,
    wait_for_active_idle_without_error,
    xfail_otelcol_logs,
)

TF_FILE = Path(__file__).parent.resolve() / "track-3.1.tf"
S3_ENDPOINT = {
    "s3_endpoint": os.getenv("S3_ENDPOINT"),
    "s3_secret_key": os.getenv("S3_SECRET_KEY"),
    "s3_access_key": os.getenv("S3_ACCESS_KEY"),
}


def test_envvars():
    assert all(S3_ENDPOINT.values()), (
        f"export the following env vars (upper case) before running this test: {S3_ENDPOINT.keys()}"
    )


def test_deploy_without_mesh(tf_manager, cos_model: jubilant.Juju):
    # GIVEN a module deployed without service mesh enabled
    tf_manager.init(TF_FILE)
    tf_manager.apply(model=cos_model.model, mesh=False, **S3_ENDPOINT)

    # THEN the model is upgraded and is healthy
    generic_assertions(cos_model)


@xfail_otelcol_logs
def test_no_errors_in_otelcol_logs(cos_model: jubilant.Juju):
    no_errors_in_otelcol_logs(cos_model)


def test_deploy_with_mesh(
    tf_manager, cos_model: jubilant.Juju, istio_model: jubilant.Juju
):
    # WHEN deployed with service mesh enabled
    tf_manager.init(TF_FILE)
    tf_manager.apply(
        model=cos_model.model, istio_model=istio_model.model, mesh=True, **S3_ENDPOINT
    )

    # THEN the Istio control plane is healthy and the model is upgraded and healthy
    wait_for_active_idle_without_error([istio_model])
    generic_assertions(cos_model)
    no_errors_in_otelcol_logs(cos_model)

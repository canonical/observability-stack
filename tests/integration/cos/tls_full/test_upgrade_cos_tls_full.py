"""There are 2 sections of the COS deployment (internal and external) which can implement TLS
communication. This python test file deploys COS with external and internal TLS.

For more further TLS configuration details, refer to our documentation:
https://documentation.ubuntu.com/observability/latest/how-to/configure-tls-encryption/"""

import os
from pathlib import Path
from subprocess import CalledProcessError

import jubilant
import pytest
from helpers import wait_for_active_idle_without_error
from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_fixed

TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"
S3_ENDPOINT = {
    "s3_endpoint": os.getenv("S3_ENDPOINT"),
    "s3_secret_key": os.getenv("S3_SECRET_KEY"),
    "s3_access_key": os.getenv("S3_ACCESS_KEY"),
}


@retry(
    retry=retry_if_exception_type(CalledProcessError),
    wait=wait_fixed(10),
    stop=stop_after_attempt(3),
    reraise=True,
)
def apply_with_retry(tf_manager, **kwargs):
    # FIXME: https://github.com/juju/terraform-provider-juju/issues/955
    tf_manager.apply(**kwargs)


def test_envvars():
    print(f"+++{S3_ENDPOINT}")
    assert all(S3_ENDPOINT.values())


@pytest.mark.xfail(reason="When host is resource-constrained, model can take too long to settle")
def test_deploy_from_track(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module deployed from track n
    tf_manager.init(TRACK_2_TF_FILE)
    # NOTE: "Terraform cannot predict how many instances will be created. To work around this,
    # use the -target argument to first apply only the resources that the count depends on."
    apply_with_retry(
        tf_manager,
        **{
            **{
                "target": "ssc",
                "ca_model": ca_model.model,
                "cos_model": cos_model.model,
            },
            **S3_ENDPOINT,
        },
    )
    apply_with_retry(
        tf_manager,
        **{**{"ca_model": ca_model.model, "cos_model": cos_model.model}, **S3_ENDPOINT},
    )
    wait_for_active_idle_without_error([cos_model], timeout=2400)

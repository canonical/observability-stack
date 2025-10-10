import os
import shutil

import pytest
from helpers import run_live

import jubilant


def test_init_cos_lite(tmpdir):
    temp_tf_dir = tmpdir.mkdir("terraform")
    shutil.copy("cos-lite.tf", temp_tf_dir)
    os.chdir(temp_tf_dir)
    run_live("terraform init")


@pytest.mark.abort_on_fail
def test_terraform_upgrade(juju: jubilant.Juju):
    run_live(
        f"terraform apply -var model={juju.model} -var channel=1/stable -auto-approve"
    )
    juju.wait(jubilant.all_agents_idle, delay=30, timeout=60 * 10)
    run_live(
        f"terraform apply -var model={juju.model} -var channel=2/edge -auto-approve"
    )
    juju.wait(jubilant.all_agents_idle, delay=30, timeout=60 * 10)


@pytest.mark.abort_on_fail
@pytest.mark.skip(reason='Traefik hits error state on destroying the model due to hook failed: "receive-ca-cert-relation-broken"')
def test_terraform_destroy(juju: jubilant.Juju):
    run_live(
        f"terraform destroy -var model={juju.model} -var channel=2/edge -auto-approve"
    )

# FIXME: We let jubilant forcefully tear down the model since TF cannot

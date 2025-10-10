# 1. We could try to test TLS transition scenarios
#       No TLS -> TLS
import pytest
import sh
import jubilant
import shutil
import os


def test_init_cos_lite(tmpdir):
    temp_tf_dir = tmpdir.mkdir("terraform")
    shutil.copy("cos-lite.tf", temp_tf_dir)
    os.chdir(temp_tf_dir)
    sh.terraform("init")


@pytest.mark.abort_on_fail
def test_terraform_upgrade(juju: jubilant.Juju):
    sh.terraform(
        "apply",
        "-var",
        "channel=1/stable",
        "-var",
        f"model={juju.model}",
        "-auto-approve",
    )
    juju.wait(jubilant.all_agents_idle, delay=30, timeout=60 * 10)
    sh.terraform(
        "apply",
        "-var",
        "channel=2/edge",
        "-var",
        f"model={juju.model}",
        "-auto-approve",
    )
    juju.wait(jubilant.all_agents_idle, delay=30, timeout=60 * 10)


@pytest.mark.abort_on_fail
# @pytest.mark.skip(reason='Traefik hits error state on destroying the model due to hook failed: "receive-ca-cert-relation-broken"')
def test_terraform_destroy(juju: jubilant.Juju):
    sh.terraform(
        "destroy",
        "-var",
        "channel=2/edge",
        "-var",
        f"model={juju.model}",
        "-auto-approve",
    )

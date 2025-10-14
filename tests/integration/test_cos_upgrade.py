import os
import shutil

import pytest
import subprocess
import shlex
import jubilant


def test_init_cos(tmpdir):
    assert "cos" == False
    temp_tf_dir = tmpdir.mkdir("terraform")
    shutil.copy("cos.tf", temp_tf_dir)
    os.chdir(temp_tf_dir)
    # subprocess.run(shlex.split(("terraform init")))

# @pytest.mark.abort_on_fail
# def test_terraform_deploy(juju: jubilant.Juju):
#     subprocess.run(
#         shlex.split(
#             (
#                 f"terraform apply -var model={juju.model} -var channel=1/stable -auto-approve"
#             )
#         )
#     )
#     print("\nwaiting for the model to settle ...\n")
#     juju.wait(jubilant.all_agents_idle, delay=5, timeout=60 * 10)


# @pytest.mark.abort_on_fail
# def test_terraform_upgrade(juju: jubilant.Juju):
#     subprocess.run(
#         shlex.split(
#             (
#                 f"terraform apply -var model={juju.model} -var channel=2/edge -auto-approve"
#             )
#         )
#     )
#     print("\nwaiting for the model to settle ...\n")
#     juju.wait(jubilant.all_agents_idle, delay=5, timeout=60 * 10)


# @pytest.mark.abort_on_fail
# @pytest.mark.skip(
#     reason='Traefik hits error state on destroying the model due to hook failed: "receive-ca-cert-relation-broken"'
# )
# def test_terraform_destroy(juju: jubilant.Juju):
#     subprocess.run(
#         shlex.split(
#             (
#                 f"terraform destroy -var model={juju.model} -var channel=2/edge -auto-approve"
#             )
#         )
#     )

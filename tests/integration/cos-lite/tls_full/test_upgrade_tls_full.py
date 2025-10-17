from pathlib import Path

import jubilant
import pytest
from helpers import wait_for_active_idle_without_error

TRACK_1_TF_FILE = Path(__file__).parent.resolve() / "track-1.tf"
TRACK_2_TF_FILE = Path(__file__).parent.resolve() / "track-2.tf"


@pytest.mark.abort_on_fail
def test_deploy_from_track(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju
):
    # GIVEN a module sourced from track n-1
    tf_manager.init(TRACK_1_TF_FILE)
    # WHEN deployed with Terraform
    tf_manager.apply(
        # NOTE: "Terraform cannot predict how many instances will be created. To work around this,
        # use the -target argument to first apply only the resources that the count depends on."
        target="ssc",
        ca_model=ca_model.model,
        cos_model=cos_model.model,
    )
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)
    # THEN the model is active/idle
    wait_for_active_idle_without_error([ca_model, cos_model])


@pytest.mark.abort_on_fail
def test_deploy_to_track(tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju):
    # GIVEN a module sourced from track n
    tf_manager.init(TRACK_2_TF_FILE)
    # WHEN deployed with Terraform
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model)
    # THEN the model is upgraded and is active/idle
    wait_for_active_idle_without_error([ca_model, cos_model])

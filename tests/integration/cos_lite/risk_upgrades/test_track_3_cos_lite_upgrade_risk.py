from pathlib import Path

import jubilant
from helpers import generic_assertions

TF_FILE = Path(__file__).parent.parent.resolve() / "tls_full/track-3.0.tf"


def test_deploy_from_stable(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju, tmp_path
):
    # GIVEN a module deployed with a "stable" risk
    tf_manager.init(TF_FILE)
    tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model, risk="stable")
    generic_assertions(cos_model, ca_model, tmp_path)


def test_upgrade_path(
    tf_manager, ca_model: jubilant.Juju, cos_model: jubilant.Juju, tmp_path
):
    # WHEN upgraded to higher risk
    for risk in ["candidate", "beta", "edge"]:
        tf_manager.init(TF_FILE)
        tf_manager.apply(ca_model=ca_model.model, cos_model=cos_model.model, risk=risk)

        # THEN the model is upgraded and is healthy
        generic_assertions(cos_model, ca_model, tmp_path)

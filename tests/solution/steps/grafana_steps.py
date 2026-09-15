#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Steps for features/grafana.feature."""

from helpers import datasources_healthy, eventually
from pytest_bdd import parsers, then

DATASOURCE_TIMEOUT = 300


@then(parsers.parse("Grafana has a datasource of type {kind}"))
def grafana_has_datasource_of_type(grafana, kind: str):
    assert eventually(grafana.has_datasource, type=kind, timeout=DATASOURCE_TIMEOUT), (
        f"Grafana has no datasource of type {kind!r}"
    )


@then(parsers.parse("the {kind} datasource is healthy"))
def datasource_is_healthy(grafana, kind: str):
    assert eventually(datasources_healthy, grafana, kind, timeout=DATASOURCE_TIMEOUT), (
        f"Grafana reports a {kind!r} datasource as unhealthy"
    )

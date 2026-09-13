#!/usr/bin/env python3
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
"""Steps for features/self_monitoring.feature."""

from helpers import eventually, logql_has_result, promql_has_result
from pytest_bdd import parsers, then

SCRAPE_TIMEOUT = 300
LOG_TIMEOUT = 300
RULES_TIMEOUT = 300
DASHBOARD_TIMEOUT = 300
ALERT_TIMEOUT = 600


@then(parsers.parse("Prometheus reports {component} as up"))
def prometheus_reports_component_up(prometheus, component: str):
    promql = f'up{{juju_application="{component}"}} == 1'
    assert eventually(promql_has_result, prometheus, promql, timeout=SCRAPE_TIMEOUT), (
        f"{promql} returned no series"
    )


@then(parsers.parse("Loki has log lines from {component}"))
def loki_has_log_lines_from(loki, component: str):
    selector = f'{{juju_application="{component}"}}'
    assert eventually(logql_has_result, loki, selector, timeout=LOG_TIMEOUT), (
        f"Loki has no log lines for {selector}"
    )


@then(parsers.parse("Prometheus has alert rules from {component}"))
def prometheus_has_alert_rules_from(prometheus, component: str):
    labels = {"juju_application": component}
    assert eventually(prometheus.has_alert_rules, labels, timeout=RULES_TIMEOUT), (
        f"Prometheus has no alert rules labelled {labels}"
    )


@then(parsers.parse("Grafana has a dashboard titled {title}"))
def grafana_has_dashboard_titled(grafana, title: str):
    assert eventually(grafana.has_dashboard, title=title, timeout=DASHBOARD_TIMEOUT), (
        f"Grafana has no dashboard titled {title!r}"
    )


@then(parsers.parse("Alertmanager has the {name} alert active"))
def alertmanager_has_alert_active(alertmanager, name: str):
    assert eventually(alertmanager.has_active_alert, name, timeout=ALERT_TIMEOUT), (
        f"{name} is not an active alert in Alertmanager"
    )

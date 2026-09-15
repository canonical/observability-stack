@cos-lite
Feature: COS Lite monitors itself
  COS Lite components are scraped by Prometheus and ship their logs, alert
  rules and dashboards to Loki, Prometheus and Grafana.

  Background:
    Given the solution has been deployed

  Scenario Outline: Prometheus scrapes <component>
    Then Prometheus reports <component> as up

    Examples:
      | component    |
      | alertmanager |
      | grafana      |
      | loki         |
      | prometheus   |
      | traefik      |

  Scenario Outline: Loki holds the logs of <component>
    Then Loki has log lines from <component>

    Examples:
      | component    |
      | alertmanager |
      | grafana      |
      | prometheus   |

  Scenario Outline: Prometheus has the alert rules of <component>
    Then Prometheus has alert rules from <component>

    Examples:
      | component    |
      | alertmanager |
      | grafana      |
      | loki         |
      | traefik      |

  Scenario Outline: Grafana has the dashboard of <component>
    Then Grafana has a dashboard titled <title>

    Examples:
      | component    | title                          |
      | alertmanager | Alertmanager Operator Overview |
      | grafana      | Grafana Operator Overview      |
      | loki         | Loki Operator Overview         |
      | prometheus   | Prometheus Operator Overview   |

  Scenario: The Watchdog alert from Alertmanager reaches Alertmanager
    Then Alertmanager has the Watchdog alert active

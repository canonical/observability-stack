Feature: Dashboard aggregation
  Grafana aggregates the dashboards shipped by the other components.

  Every dashboard carries a `charm: <charm-name>` tag identifying the charm
  that provided it, which is more stable than matching dashboard titles.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite
  Scenario Outline: Grafana receives dashboards from a component
    Then Grafana has a dashboard from the "<charm>" charm

    Examples:
      | charm            |
      | alertmanager-k8s |
      | loki-k8s         |
      | prometheus-k8s   |

  @cos
  Scenario Outline: Grafana receives dashboards from a component
    Then Grafana has a dashboard from the "<charm>" charm

    Examples:
      | charm                       |
      | alertmanager-k8s            |
      | loki-coordinator-k8s        |
      | mimir-coordinator-k8s       |
      | opentelemetry-collector-k8s |
      | tempo-coordinator-k8s       |

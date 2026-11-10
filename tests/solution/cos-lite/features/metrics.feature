Feature: Metrics collection
  The metrics backend scrapes every component that exposes metrics.

  Background:
    Given the solution has been deployed
    And the model is healthy

  Scenario Outline: Prometheus collects metrics from a component
    Then Prometheus has metrics from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | loki         |
      | prometheus   |

  Scenario: Prometheus collects metrics from Traefik
    Given the solution is deployed with an ingress
    Then Prometheus has metrics from the "traefik" application

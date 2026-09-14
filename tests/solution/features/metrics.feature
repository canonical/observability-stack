Feature: Metrics collection
  The metrics backend scrapes every component that exposes metrics.

  Each component's metrics carry a `juju_application` label, so looking for
  that label proves the metrics came from that specific application.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite
  Scenario Outline: Prometheus collects metrics from a component
    Then Prometheus has metrics from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | loki         |
      | traefik      |

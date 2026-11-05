Feature: Metrics collection
  The metrics backend scrapes every component that exposes metrics.

  Background:
    Given the solution has been deployed
    And the model is healthy

  Scenario Outline: Mimir collects metrics from a component
    Then Mimir has metrics from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | loki         |
      | mimir        |
      | tempo        |

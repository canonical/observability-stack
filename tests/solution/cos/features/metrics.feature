Feature: Metrics collection
  The metrics backend scrapes every component that exposes metrics.

  Background:
    Given the solution has been deployed
    And the model is healthy

  # In COS, components do not expose metrics to Mimir directly: Otelcol scrapes
  # them and remote-writes to Mimir. The assertion is the same either way, since
  # `juju_application` identifies the component the metrics originated from,
  # not the one that delivered them.
  Scenario Outline: Mimir collects metrics from a component
    Then Mimir has metrics from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | loki         |
      | mimir        |
      | tempo        |

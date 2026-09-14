Feature: Log collection
  The logs backend ingests logs from every component that ships them.

  Each component's log streams carry a `juju_application` label, so looking
  for that label proves the logs came from that specific application.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite
  Scenario Outline: Loki collects logs from a component
    Then Loki has logs from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | prometheus   |

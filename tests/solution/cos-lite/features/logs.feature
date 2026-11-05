Feature: Log collection
  The logs backend ingests logs from every component that ships them.

  Background:
    Given the solution has been deployed
    And the model is healthy

  Scenario Outline: Loki collects logs pushed to it directly
    Then Loki has logs from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | prometheus   |

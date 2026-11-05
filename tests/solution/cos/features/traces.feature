Feature: Trace collection
  The traces backend ingests the charm traces emitted by every component that
  is instrumented.

  Background:
    Given the solution has been deployed
    And the model is healthy

  Scenario Outline: Tempo collects traces from a component
    Then Tempo has traces from the "<application>" application

    Examples:
      | application |
      | grafana     |
      | loki        |
      | mimir       |
      | tempo       |

Feature: Datasource configuration
  Grafana is configured with a datasource for every queryable component.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite
  Scenario Outline: Grafana has a working datasource for a component
    Then Grafana has a datasource for the "<application>" application
    And that datasource is healthy

    Examples:
      | application  |
      | alertmanager |
      | loki         |
      | prometheus   |

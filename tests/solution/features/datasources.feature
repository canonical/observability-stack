Feature: Datasource configuration
  Grafana is configured with a datasource for every queryable component.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite
  Scenario Outline: Grafana has a datasource for a component
    Then Grafana has a datasource for the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | loki         |
      | prometheus   |

  # Grafana's Alertmanager datasource has no backend health check, so it is
  # absent here: its health endpoint reports the plugin as unavailable.
  @cos-lite
  Scenario Outline: Grafana's datasource for a component is healthy
    Then Grafana has a datasource for the "<application>" application
    And that datasource is healthy

    Examples:
      | application |
      | loki        |
      | prometheus  |

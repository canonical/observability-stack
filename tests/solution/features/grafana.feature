@cos-lite
Feature: Grafana datasources
  Grafana has a datasource for every component integrated with it over
  grafana-source.

  Background:
    Given the solution has been deployed

  Scenario Outline: Grafana has a healthy <type> datasource
    Then Grafana has a datasource of type <type>
    And the <type> datasource is healthy

    Examples:
      | type       |
      | prometheus |
      | loki       |

  Scenario: Grafana has an alertmanager datasource
    Then Grafana has a datasource of type alertmanager

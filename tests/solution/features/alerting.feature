@cos-lite
Feature: Alerting
  Alert rules a workload ships over its metrics-endpoint integration are
  loaded by Prometheus, and the alerts they raise reach Alertmanager.

  Background:
    Given the solution has been deployed
    And Avalanche is integrated with the solution

  Scenario: Prometheus loads the alert rules of Avalanche
    Then Prometheus has alert rules from avalanche

  Scenario Outline: <alert> from Avalanche reaches Alertmanager
    Then Alertmanager has the <alert> alert active

    Examples:
      | alert                         |
      | AlwaysFiringDueToAbsentMetric |
      | AlwaysFiringDueToNumericValue |

Feature: TLS

  Scenario Outline: A component's certificate matches the deployment's TLS mode
    Given the solution has been deployed
    And the model is healthy
    Then <component> serves traffic using the deployment's internal TLS mode
    And <component>'s certificate is trusted by the deployment's internal CA
    And <component>'s certificate is trusted by the deployment's external CA

    Examples:
      | component    |
      | alertmanager |
      | grafana      |
      | loki         |
      | prometheus   |

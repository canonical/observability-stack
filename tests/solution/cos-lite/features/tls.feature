Feature: TLS

  Scenario: prometheus's certificate matches the deployment's TLS mode
    Given the solution has been deployed
    And the model is healthy
    Then prometheus serves traffic using the deployment's internal TLS mode
    And prometheus's certificate is trusted by the deployment's configured CA

Feature: TLS

  Scenario: mimir's certificate matches the deployment's TLS mode
    Given the solution has been deployed
    And the model is healthy
    Then mimir serves traffic using the deployment's internal TLS mode
    And mimir's certificate is trusted by the deployment's configured CA

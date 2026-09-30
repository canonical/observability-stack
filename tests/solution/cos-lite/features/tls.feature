Feature: Internal TLS
  COS Lite deploys internal TLS by default, controlled by the `internal_tls`
  Terraform variable. There is only one scenario here, not one per mode: the
  step asks the deployment which mode is live and asserts accordingly, so it
  runs unmodified whichever way `internal_tls` was set.

  Background:
    Given the solution has been deployed
    And the model is healthy

  Scenario: A component is served over the scheme internal TLS implies
    Then the "prometheus" application is served over the scheme internal TLS implies

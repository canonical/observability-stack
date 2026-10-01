Feature: Ingress
  COS Lite fronts every component with Traefik by default, controlled by the
  `ingress` Terraform variable. There is only one scenario here, not one per
  mode: the step asks the deployment whether ingress is live and asserts
  accordingly, so it runs unmodified whichever way `ingress` was set.

  Background:
    Given the solution has been deployed
    And the model is healthy

  Scenario: Traefik is deployed iff ingress is enabled
    Then the "traefik" application is deployed iff ingress is enabled

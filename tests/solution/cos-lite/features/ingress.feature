Feature: Ingress mode
  COS Lite fronts every component with Traefik by default, controlled by the
  `ingress` Terraform variable, exposed here as a blanket on/off `ingress_mode`.

  Only one of these two scenarios runs per invocation, per `SOLUTION_MODES`.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @ingress
  Scenario: Traefik is deployed when ingress is enabled
    Then the "traefik" application is deployed

  @no-ingress
  Scenario: No reverse proxy is deployed when ingress is disabled
    Then the "traefik" application is not deployed

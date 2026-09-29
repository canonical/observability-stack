Feature: Internal TLS mode
  COS Lite deploys internal TLS by default, controlled by the `internal_tls`
  Terraform variable, exposed here as the `tls_internal`/`tls_none` modes.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite @tls_internal
  Scenario: Components are served over HTTPS when internal TLS is enabled
    Then the "prometheus" application is served over "https"

  @cos-lite @tls_none
  Scenario: Components are served over plain HTTP when internal TLS is disabled
    Then the "prometheus" application is served over "http"

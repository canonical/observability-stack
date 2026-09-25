Feature: Internal TLS mode
  COS Lite's `internal_tls` Terraform variable controls whether components
  talk to each other (and are reachable) over HTTPS or plain HTTP. Each mode
  dir (`tls_internal`, `tls_none`) fixes that variable to one value; the
  scenario tagged for the active solution+mode combination is the one that
  runs.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite @tls_internal
  Scenario: Components are served over HTTPS when internal TLS is enabled
    Then the "prometheus" application is served over "https"

  @cos-lite @tls_none
  Scenario: Components are served over plain HTTP when internal TLS is disabled
    Then the "prometheus" application is served over "http"

Feature: TLS
  With internal TLS, every component serves HTTPS with a certificate from the deployment's CA,
  issued for each unit's in-cluster FQDN; without it, the components serve plain HTTP. With an
  external CA, the certificates Traefik serves for the components are signed by it.

  Background:
    Given the solution has been deployed
    And the model is healthy

  Scenario Outline: With internal TLS, a component's units serve certificates from the internal CA
    Given the solution is deployed with internal TLS
    Then <component>'s units serve certificates for their in-cluster FQDN, signed by the internal CA

    Examples:
      | component    |
      | alertmanager |
      | grafana      |
      | loki         |
      | prometheus   |

  Scenario Outline: Without internal TLS, a component serves plain HTTP
    Given the solution is deployed without internal TLS
    Then <component> serves plain HTTP

    Examples:
      | component    |
      | alertmanager |
      | grafana      |
      | loki         |
      | prometheus   |

  Scenario Outline: With an external CA, a component's ingress certificate is signed by it
    Given the solution is deployed with an external CA
    And <component> is exposed through the ingress
    Then <component>'s ingress certificate is signed by the external CA

    Examples:
      | component    |
      | alertmanager |
      | grafana      |
      | loki         |
      | prometheus   |

Feature: Log collection
  The logs backend ingests logs from every component that ships them.

  Background:
    Given the solution has been deployed
    And the model is healthy

  @cos-lite
  Scenario Outline: Loki collects logs pushed to it directly
    Then Loki has logs from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | prometheus   |

  # In COS, components do not push logs to Loki directly: Otelcol receives them
  # and forwards them on. Otelcol appears in the table too, since it forwards
  # its own internal logs alongside everyone else's.
  @cos
  Scenario Outline: Loki collects logs forwarded by Otelcol
    Then Loki has logs from the "<application>" application

    Examples:
      | application  |
      | alertmanager |
      | grafana      |
      | loki         |
      | mimir        |
      | otelcol      |
      | tempo        |

Feature: Trace collection
  The traces backend ingests the charm traces emitted by every component that
  is instrumented.

  Charms emit their traces to Otelcol, which forwards them to Tempo. Spans
  carry a `juju_application` resource attribute, so looking for that attribute
  proves the traces came from that specific application.

  Background:
    Given the solution has been deployed
    And the model is healthy

  # COS Lite ships no traces backend, so this feature is COS-only.
  @cos
  Scenario Outline: Tempo collects traces from a component
    Then Tempo has traces from the "<application>" application

    Examples:
      | application |
      | grafana     |
      | loki        |
      | mimir       |
      | tempo       |

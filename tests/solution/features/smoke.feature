Feature: Solution smoke test
  A minimal health check for a deployed solution (e.g. COS, COS Lite):
  once deployed, every application should become active and every unit
  agent should become idle.

  This does not assert anything about the functionality of individual
  components; see tests/integration for that.

  Scenario: A deployed solution settles into a healthy state
    Given the solution has been deployed
    Then the model settles into a healthy state

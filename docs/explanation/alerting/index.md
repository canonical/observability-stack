---
myst:
  html_meta:
    description: "Built-in alerting rules, charmed and generic alert management, and dashboard upgrade handling in COS."
---

(alerting)=

# Alerting & dashboards

Guidance about built-in alerting, charmed alert rules, and how rules and
dashboards are managed across the stack.

## Alert rule management

How COS defines, ships, and orchestrates alert rules, both charm-provided
and generic.

```{toctree}
:maxdepth: 1

Charmed alert rules <charmed-rules>
Generic alert rules <generic-rules>
```

## Dashboard lifecycle

How dashboards are upgraded and deduplicated as charms evolve.

```{toctree}
:maxdepth: 1

Dashboard upgrades and deduplication <dashboard-upgrades>
```

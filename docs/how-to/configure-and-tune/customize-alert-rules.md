---
myst:
  html_meta:
    description: "Customize alert rules in COS using remove and patch operations. Fine-tune relation-derived alerts without disrupting built-in monitoring."
---

# How to customize alert rules

COS charms that evaluate alert rules (Prometheus, Loki, Mimir) receive rules
from related applications over relation data. You can fine-tune these
relation-derived rules at the charm level without modifying the upstream charm.
This is useful when you need to adjust alert thresholds, relabel alerts, or
drop noisy rules in your specific deployment.

The `alert_rule_customizations` config option (type `string`, YAML) accepts
two top-level operations: `remove` and `patch`. The charm parses and validates
the configuration, applies the transformations to all incoming alert rules,
and re-validates the result. If any step fails the original rules are kept
unchanged.

## The base concepts

The configuration is a YAML mapping that supports two optional top-level keys:

`remove`
: A list of operations that drop matching alerting rules.

`patch`
: A list of operations that merge a `set` block into matching alerting rules.

Each operation contains a `where` block that selects which rules to act on.
`patch` operations also contain a `set` block that describes what to change.

All fields in a single `where` block are ANDed: a rule must satisfy every
selector to match. Multiple `where` entries in the `remove` or `patch` list
are ORed: a rule that matches any entry is affected.

### Matching rules with `where`

A `where` block supports these selectors:

| Key | Match behaviour |
| --- | --- |
| `alert` | Exact match on the rule name |
| `group` | Exact match on the group name |
| `labels` | Every listed key-value pair must exist in the rule's labels |
| `annotations` | Every listed key-value pair must exist in the rule's annotations |

```{important}
Group names are auto-generated and contain the Juju model UUID. They are not
stable across model re-deployment. Prefer matching by `alert` name or `labels`
for reliable targeting.
```

This is an example of a `where` block that targets a specific alert with a specific label:

```yaml
where:
  alert: HostDown
  labels:
    juju_application: aval
```

This matches only the `HostDown` alert that also has the label
`juju_application: aval`.

### What you can change with `set`

A `set` block inside a `patch` operation supports these fields:

| Key | Effect |
| --- | --- |
| `alert` | Rename the alert |
| `expr` | Replace the entire alert expression |
| `for` | Change the duration (e.g. `10m`, `1h`) |
| `labels` | Merge new or updated labels into the rule |
| `annotations` | Merge new or updated annotations into the rule |


Labels and annotations in a `set` block are merged into the existing
labels/annotations. They overwrite existing entries with the same key and
add new ones. There is currently no way to delete individual labels or
annotations.

## Using `remove`

A `remove` operation drops matching alerting rules. Recording rules are never
individually removed. They are only removed when an entire group is dropped.

When `group` is the **only** selector in the `where` block (no `alert`,
`labels`, or `annotations), the entire group is dropped, recording rules
included.

### Remove by alert name

```yaml
remove:
  - where:
      alert: TargetDown
```

### Remove by labels

```yaml
remove:
  - where:
      labels:
        environment: staging
  - where:
      labels:
        environment: production
        zone: can-west
```

The first entry removes all alerting rules tagged `environment: staging`.
The second entry removes alerting rules tagged with **both**
`environment: production` and `zone: can-west`.

### Remove an entire group

```yaml
remove:
  - where:
      group: noisy_group
```

Because `group` is the only selector, this drops the entire group including
any recording rules it contains.

## Using `patch`

A `patch` operation merges a `set` block into every matching alerting rule.
Recording rules are never patched.

### Change the `for` duration

```yaml
patch:
  - where:
      alert: HostDown
    set:
      for: 25m
```

### Merge additional labels

```yaml
patch:
  - where:
      alert: HighLatency
    set:
      labels:
        severity: warning
```

This adds `severity: warning` to the rule if not present, or overwrites an
existing `severity` label with `warning`.

### Rename an alert

```yaml
patch:
  - where:
      alert: OldAlertName
    set:
      alert: NewAlertName
```

### Replace the expression
```{warning}
Replacing `expr` requires retyping the full PromQL or LogQL expression,
including all Juju topology matchers that the charm injects automatically.
Omitting a matcher will cause the alert to lose its model and application
scoping. The charm re-validates the resulting expression via cos-tool and
will reject invalid expressions.
```

```yaml
patch:
  - where:
      alert: HostDown
    set:
      expr: up == 0 or absent(up)
```

## Combining `remove` and `patch`

Operations run in this order: `remove` first, then `patch`. The input rules
are never mutated. Transformations operate on a deep copy.

```yaml
remove:
  - where:
      alert: NoisyAlert
  - where:
      group: deprecated_group
patch:
  - where:
      alert: HostDown
    set:
      for: 25m
  - where:
      labels:
        severity: critical
    set:
      labels:
        severity: warning
```

This configuration drops `NoisyAlert`, drops the entire `deprecated_group`,
extends the `for` duration of `HostDown` to 25 minutes, and changes the
severity of all critical alerts to warning.

## Patch ordering

Patches are applied sequentially to the already-modified rules. If a patch
renames an alert, subsequent patches targeting the old name will silently
miss. No warning is emitted for non-matching operations.

```{note}
A `patch` or `remove` that matches nothing is a silent no-op. The charm
remains in `ActiveStatus` and the original rules are kept unchanged.
```

## Setting the config option

```bash
juju config prometheus alert_rule_customizations='remove:
  - where:
      alert: TargetDown'
```

For multiline configurations, write the YAML to a file and pass it with `@`:

```bash
juju config prometheus alert_rule_customizations=@customizations.yaml
```

If the config is set to an empty string, no customizations are applied.

## Limitations

- Wildcard or regex matching is not supported. Selectors use only exact
  equality or label/annotation subset matching.
- Deleting individual labels or annotations is not supported. Only
  add/overwrite semantics are available.
- Patching `alert` renames the rule in-place. Subsequent patches in the same
  configuration that target the old name will not match the renamed rule.
- Editing `expr` requires retyping the full expression including Juju
  topology matchers. A mistake in the expression will cause the entire
  customization to be rejected at validation time.
- There is no `add` key. You cannot inject new rules through this mechanism.
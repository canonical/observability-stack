---
myst:
 html_meta:
   description: "Diagnose false-positive (noisy) and false-negative (silent) alerts in the Canonical Observability Stack."
---

# How to diagnose false alerts

False alerts fall into two categories:

- False positives (noisy alerts), are alerts that fire when they should not, usually due to
  overly broad label matching or an inappropriate threshold in the PromQL/LogQL expression.
- False negatives, are alerts that do *not* fire when they should. This can be due
  to an unintentional label mismatch in the alert expression, a threshold that is too lenient,
  or the alert rule being missing entirely — either because it was not forwarded over Juju
  relation data or was not serialized to disk correctly.

## Diagnose false-positive (noisy) alerts

From the Alertmanager UI, note the rule name, labels and expression (`expr`).
In Grafana, evaluate the expression manually by pasting the alert expression into the Grafana query UI.
Inspect which time series match. Look for:

- Overly broad label selectors: the expression may match time series from charms or units
  that were not intended. Compare the label matchers in the expression against the actual labels
  on the returned time series.
- Juju topology label mismatches: charmed alert rules are
  [automatically injected](/explanation/architecture/juju-topology) with topology matchers. If the
  topology labels on the time series do not match what was injected, the wrong set of series may be selected. 
  Query `up` in Prometheus and compare the topology labels there against your expression.
- Threshold too sensitive: the threshold in the expression may be too aggressive for your
  environment. For example, a CPU usage alert firing at 80% may be normal for your workload.
  [Charmed alert rule](/explanation/alerting/charmed-rules) thresholds are opinionated and not
  configurable, so if the threshold is inappropriate you may need to silence the alert or file
  a bug against the charm.

Depending on the root cause:

- Silence the alert in the Alertmanager UI, or come up with apropriate inhibit rules.
- [Disable rule forwarding](/how-to/configure-and-tune/disable-charmed-rules) on the aggregator
  (e.g. `opentelemetry-collector`) if all rules from a particular aggregator are unwanted.
- File a bug against the upstream charm if the charmed rule threshold is inappropriate for
  general use.

## Diagnose false-negative alerts

### Confirm the alert rule exists

First, verify that the alert rule is actually loaded in Prometheus or Loki.
If you know the name of the alert (can be found in the source code of the relevant charm),
inspect the relation databag for the relevant unit with `juju show-unit`.

If the rule is not present:

- Check if rule forwarding is disabled: the `forward_alert_rules` config option on aggregators
  such as `opentelemetry-collector`, `cos-proxy`, or `prometheus-scrape-config` may be set to
  `false`. Verify with:
  ```bash
  juju config opentelemetry-collector forward_alert_rules
  ```
- Check the charm's built-in rules: charmed alert rules are typically located at
  `./src/prometheus_alert_rules` and `./src/loki_alert_rules` relative to the charm's source
  tree. If the rule file is missing from the charm or stored in a non-default location, 
  our charm libraries may not have picked it up.
- For rules synced from a Git repository via the
  [COS Configuration charm](/how-to/configure-and-tune/sync-alert-rules-from-git), confirm that
  the rule file exists in the repository and that the charm is polling successfully.

### Check the alert expression

If the rule exists in Prometheus or Loki but does not fire when you expect it to, the issue is in
the expression itself.

Evaluate the expression manually by pasting the alert expression into the Grafana query UI.
If it returns no results or only `0`, the condition for the alert is never met.

Common causes:

- Label matchers too narrow: the [juju topology](/explanation/architecture/juju-topology)
  matchers injected into charmed rules qualify the expression so it applies only to a specific
  charm. If the topology labels on the actual time series differ from what was injected (for
  example, after a charm rename or model migration), the expression will not match any series.
  Query `up{}` and compare the label values against the matchers in the alert expression.
- Metric does not exist: the metric name referenced in the expression may not be emitted by
  your workload, or may have been renamed in a newer version of the workload. Check the metrics
  endpoint directly, for example
  ```bash
  juju ssh <unit/0> curl -s localhost:<port>/metrics | grep <metric_name>
  ```
- Threshold too lenient: the alert threshold may be higher (or lower) than the values your
  workload produces, so the condition is never satisfied. Evaluate the expressions in the
  alert incrementally to see what values they return.
- Alert uses `absent()`: the `absent()` function returns `1` when the given selector matches
  *no* time series at all, and is commonly used to detect missing metrics. However, `absent()`
  does not support wildcard or regex label matchers — if the selector contains a regex matcher
  (e.g. `juju_unit=~".+"`), `absent()` will never fire because it cannot determine which label
  values are "expected". Alert rules that rely on `absent()` must use exact label matchers.
- Threshold derived from a Grafana dashboard: if the alert threshold was chosen based on values
  observed in a Grafana panel, be aware that Grafana can apply post-query axis scaling that
  changes the displayed values. For example, a panel may show a "percentage" axis (0–100) while
  the underlying PromQL expression returns a ratio (0–1), or a panel may display bytes while the
  raw metric is in kilobytes. Always verify the raw query result in the Grafana query inspector
  or directly in the Prometheus UI before setting a threshold.

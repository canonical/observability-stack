# Dashboard upgrades and deduplication

A dashboard JSON file can change in your charm, but Grafana may still keep
showing the previous version. This has been a common source of confusion for
charm authors.

This happens because dashboard delivery in COS is deduplicated. The
deduplication logic is designed to avoid repeatedly re-importing the same
dashboard content when relation data is refreshed.

This feature is available in the [grafana_dashboard](https://charmhub.io/grafana-k8s/libraries/grafana_dashboard)
library starting v0.47.

## Why this happens

Built-in dashboards are forwarded over the `grafana_dashboard` integration.
When the grafana charm processes dashboard updates, it does not treat every relation-data
change as a new dashboard revision. Instead, it compares dashboard identity
and revision metadata to decide whether an update is meaningful.

In practice, this means that editing panel queries, titles, or layout without
changing the dashboard `version` can be interpreted as "same revision", so
the update may be ignored by the deduplication path.

## Why bumping `version` is required

For dashboard upgrades, the `version` field in the dashboard JSON is the
explicit signal that tells Grafana and the COS dashboard pipeline: "this is a
newer revision of the same dashboard".

Without a `version` bump, the grafana charm may deduplicate the payload as already
seen, and end up keeping the previously imported revision.

With a `version` bump, the update is treated as a new dashboard revision and
is imported.

## Rolling charm upgrades and mixed revisions

When a charmed application is upgraded, units are typically upgraded one at a
time, not all at once. During that window, the grafana charm can receive dashboard payloads
from both old and new unit revisions.

This is safe for dashboard upgrades: the reconciliation logic keeps the
highest dashboard `version` it has seen for a given dashboard identity. In
other words, once the newer revision is present, lower-version payloads from
not-yet-upgraded units do not roll the dashboard back.

When you ship dashboard changes in a charm release, always update the
dashboard JSON `version` field as part of the same change.

## When metrics are renamed or removed
Changes in metric names that are used in dashboard panels make a breaking change.
In this case, bumping the dashboard's `version` field is not enough, because the deduplicated
dashboard won't work for older charms (from before the metric was renamed).
The best way to address this situation is to rename the dashboard file (and `title` field,
while you're on it), so it does not collide with existing deployments that still use the old metric names.

This also applies when metrics are renamed in-track. Examples of renamed dashboard files:

- "`postgres-14-overview.json`" to "`postgres-16-overview.json`" (metric change between charm tracks)
- "`postgres-14-overview.json`" to "`postgres-14-overview-metrics-renamed.json`" (metric change within the same track)
- "`overview.json`" to "`overview-rev345plus.json`" (using charm revision as a marker)

## References

- [`grafana-k8s-operator#363`](https://github.com/canonical/grafana-k8s-operator/pull/363)
- [`grafana-k8s-operator#484`](https://github.com/canonical/grafana-k8s-operator/pull/484)

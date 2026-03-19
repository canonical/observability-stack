# Dashboard upgrades and deduplication

Issues #363 and #484 highlighted a common source of confusion for charm
authors: a dashboard JSON file can change in your charm, but Grafana may
still keep showing the previous version.

This happens because dashboard delivery in COS is deduplicated. The
deduplication logic is designed to avoid repeatedly re-importing the same
dashboard content when relation data is refreshed.

## Why this happens

Built-in dashboards are forwarded over the `grafana_dashboard` integration.
When COS processes dashboard updates, it does not treat every relation-data
change as a new dashboard revision. Instead, it compares dashboard identity
and revision metadata to decide whether an update is meaningful.

In practice, this means that editing panel queries, titles, or layout without
changing the dashboard `version` can be interpreted as "same revision", so
the update may be ignored by the deduplication path.

## Why bumping `version` is required

For dashboard upgrades, the `version` field in the dashboard JSON is the
explicit signal that tells Grafana and the COS dashboard pipeline: "this is a
newer revision of the same dashboard".

Without a `version` bump, COS may correctly deduplicate the payload as already
seen, and Grafana keeps the previously imported revision.

With a `version` bump, the update is treated as a new dashboard revision and
is imported.

## Rolling charm upgrades and mixed revisions

When a charmed application is upgraded, units are typically upgraded one at a
time, not all at once. During that window, COS can receive dashboard payloads
from both old and new unit revisions.

This is safe for dashboard upgrades: the reconciliation logic keeps the
highest dashboard `version` it has seen for a given dashboard identity. In
other words, once the newer revision is present, lower-version payloads from
not-yet-upgraded units do not roll the dashboard back.

## Mental model for charm authors

Think of dashboard upgrades as revisioned artifacts:

- dashboard UID/title identify *which* dashboard it is
- dashboard `version` identifies *which revision* of that dashboard should be applied

So when you ship dashboard changes in a charm release, always update the
dashboard JSON `version` field as part of the same change.

# Release notes

This document will contain breaking changes and upgrade steps to move from a COS track to the next one.

## Track 2

### Grafana

We upgraded the workload version from Grafana 9 to Grafana 12.

A thorough review of Grafana's breaking changes and how they affect us is available [on Discourse](https://discourse.charmhub.io/t/cos-will-start-using-grafana-12-what-changed/18868).

#### Changes to how the panel view URL is generated for repeated panels

Links to **repeated panels** in a dashboard changed slightly; previously bookmarked links specifically to a repeated panel (not its dashboard) won't work anymore.




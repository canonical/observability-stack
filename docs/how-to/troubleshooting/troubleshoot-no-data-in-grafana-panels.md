# Troubleshooting `no data` in Grafana panels

Data in Grafana panels is obtained by querying datasources.

## Adjust the time range
Check if there is any data when you change the 
[time range](https://grafana.com/docs/grafana-cloud/visualizations/dashboards/use-dashboards/#set-dashboard-time-range)
to `1d`, `7d`, etc.
Perhaps you had "no data" all along or it started happening only recently.

## Inspect variable values
Drop-down [variables](https://grafana.com/docs/grafana/latest/dashboards/variables/)
could be filtering out data incorrectly.
Under dashboard settings, inspect the current values of the variables.

## Confirm the query is valid
[Edit the panel](https://grafana.com/docs/grafana/latest/panels-visualizations/panel-editor-overview/)
and incrementally simplify the faulty query, until data shows up.
For example,
- drop label matchers
- remove aggregation operations (`on`, `sum by`)
- replace `$__` interval macros with literals such as `5s` or `5m`
- remove drop-down variables from the query
- disable transformations or overrides that could potentially hide data

Open the query inspector panel and check the response.

## Check datasource connection
Test the datasouce connection.
- URL correct?
- Credentials valid?
- Proxy configured? Proxy can be [configured](https://documentation.ubuntu.com/juju/latest/reference/configuration/list-of-model-configuration-keys/#model-config-http-proxy) per model.
- Datasource (backend) errors in the logs?
- Errors in grafana server logs?

## Test the query in the datasource UI
Some datasources (backends, e.g. Prometheus) have their own UI where you can paste the query
from the faulty Grafana panel. If the query works in the backend UI but not in Grafana,
check datasource connection.

## Confirm that the relevant juju relations are in place
- Grafana should be related over the [grafana-source](https://charmhub.io/integrations/grafana_datasource) relation to all relevant datasoures.
- In typical deplopyments, telemetry is pushed from outside the model. Make sure the backends have an ingress relation.
- For deployment that are TLS-terminated, Grafana needs a `recieve-ca-cert` relation from Traefik.

## Confirm backends are not out of disk space
If a beckend (e.g. Prometheus) runs out of disk space, then it will not ingest new
telemetry.

## Confirm you can curl the backend via its ingress URL

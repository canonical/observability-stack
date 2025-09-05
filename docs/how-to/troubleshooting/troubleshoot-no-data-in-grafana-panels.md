# Troubleshooting `no data` in Grafana panels

Data in Grafana panels is obtained by querying datasources.

## Adjust the time range
Check if there is any data when you change the time range to `1d`, `7d`, etc.
Perhaps yo had "no data" all along or it started happening only recently.

## Inspect variable values
Drop-down variables could be filtering out data incorrectly.
Under dashboard settings, inspect the current values of the variables.

## Confirm the query is valid
Edit the panel and incrementally simplify the faulty query, until data shows up.
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
Some datasources (e.g. Prometheus) have their own UI where you can paste the query
from the faulty Grafana panel.


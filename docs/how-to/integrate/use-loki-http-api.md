---
myst:
  html_meta:
    description: "Use the Loki HTTP API with Charmed Loki to inspect build information, push log entries, and configure clients such as Promtail."
---

# How to use the Loki HTTP API

Charmed Loki exposes the [Loki HTTP API](https://grafana.com/docs/loki/latest/reference/loki-http-api/) over port `3100`.

## Prerequisites

This how-to assumes that you have:

- A running COS or COS Lite deployment with Charmed Loki
- Network access to the Loki unit address
- `curl` and `jq` installed on the client machine

Set the Loki API URL for the examples in this guide:

```bash
loki_ip=$(juju status loki/0 --format=json | jq -r '.applications.loki.units."loki/0".address')
LOKI_URL="http://${loki_ip}:3100"
```

If your Loki application has a different Juju application name, replace `loki` and `loki/0` in the command.

## Get the Loki version

The `/loki/api/v1/status/buildinfo` endpoint exposes build information in a JSON object. The response includes the `version`, `revision`, `branch`, `buildDate`, `buildUser`, and `goVersion` fields.

```bash
curl "${LOKI_URL}/loki/api/v1/status/buildinfo" | jq
```

Example output:

```json
{
  "version": "2.4.1",
  "revision": "f61a4d261",
  "branch": "HEAD",
  "buildUser": "root@39a6e600b2df",
  "buildDate": "2021-11-08T13:09:51Z",
  "goVersion": ""
}
```

## Send log lines to Loki with curl

Use `/loki/api/v1/push` to send log entries to Loki. By default, the endpoint expects a snappy-compressed protobuf message. To send JSON instead, set the `Content-Type` header to `application/json`.

```bash
curl -v \
  -H "Content-Type: application/json" \
  -X POST \
  -s "${LOKI_URL}/loki/api/v1/push" \
  --data-raw '{"streams": [{"stream": {"foo": "bar2"}, "values": [["1570818238000000000", "fizzbuzz"]]}]}'
```

## Send log entries to Loki with Promtail

[Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) is an agent that ships local logs to Loki. It is usually deployed to each machine that runs applications you want to monitor.

Promtail primarily:

- Discovers targets
- Attaches labels to log streams
- Pushes log streams to Loki

Promtail can tail logs from local log files and the systemd journal.

To configure a Promtail instance to send logs to Charmed Loki, refer to the [Promtail configuration documentation](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/). The important part is the `clients` section:

```yaml
clients:
  - url: http://<LOKI_ADDRESS>:3100/loki/api/v1/push
```

Replace `<LOKI_ADDRESS>` with the Loki unit address.

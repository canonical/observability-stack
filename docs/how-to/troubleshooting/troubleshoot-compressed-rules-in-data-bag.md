# Troubleshoot compressed rules in relation data bags

In some relations, rules are compressed in the data bag and are not human readable, making troubleshooting difficult. Assuming your unit and endpoint are named `otelcol/0` and `receive-otlp` respectively, then you can view the compressed rules with:

```bash
juju show-unit otelcol/0 --format=json | \
  jq -r '."otelcol/0"."relation-info"[] | select(.endpoint == "receive-otlp") | ."application-data".rules'

> /Td6WFoAAATm1rRGAgAhARYAAAB0L ... IEAJVHNA5MGJt6AAGcCtk3AABCHzmZscRn+wIAAAAABFla
```

And decompress for troubleshooting with:
```bash
juju show-unit otelcol/0 --format=json | \
  jq -r '."otelcol/0"."relation-info"[] | select(.endpoint == "receive-otlp") | ."application-data".rules' | \
  base64 -d | xz -d | jq

> {JSON rule content ...}
```

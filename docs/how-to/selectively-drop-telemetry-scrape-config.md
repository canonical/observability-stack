# Selectively drop telemetry using scrape config

Sometimes, from a resource perspective, applications are instrumented with more telemetry than we want to afford. In such cases, we can choose to selectively drop some before they are ingested.

## Scrape config

Metrics can be dropped by using the `drop` action in several different places:
- Under [`<scrape_config>`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) section ([`<metric_relabel_configs>`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs) subsection). For example: all the self-monitoring scrape jobs that e.g. COS Lite has in place.
- Under [`<remote_write>`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write) section (`<write_relabel_configs>` subsection). For example: prometheus can be told to drop metrics before pushing them to another prometheus over remote-write API. This use case is not addressed in this guide.

###  MetricsEndpointProvider
Charms that integrate with prometheus or otelcol, provide a "scrape config" to `MetricsEndpointProvider` (imported from [`charms.prometheus_k8s.v0.prometheus_scrape`](https://charmhub.io/prometheus-k8s/libraries/prometheus_scrape)).

Let's take for example the alertmanager self-metrics that prometheus scrapes. If we do not want prometheus or otelcol to ingest any `scrape_samples_*` metrics from alertmanager, then we need to adjust the scrape job specified in the alertmanager charm:

```diff
diff --git a/src/charm.py b/src/charm.py
index fa3678c..f0e943b 100755
--- a/src/charm.py
+++ b/src/charm.py
@@ -250,6 +250,13 @@ class AlertmanagerCharm(CharmBase):
             "scheme": metrics_endpoint.scheme,
             "metrics_path": metrics_path,
             "static_configs": [{"targets": [target]}],
+            "metric_relabel_configs": [
+                {
+                    "source_labels": ["__name__"],
+                    "regex": "scrape_samples_.+",
+                    "action": "drop",
+                }
+            ]
         }
 
         return [config]
```

### scrape-config charm
In a typical scrape-config deployment such as:

```{mermaid}
graph LR
  some-external-target --- scrape-target --- scrape-config --- prometheus
```

We can specify the `drop` action via a config option for the [scrape-config charm](https://charmhub.io/prometheus-scrape-config-k8s):

```shell
$ juju config sc metric_relabel_configs="$(cat <<EOF
- source_labels: ["__name__"]
  regex: "scrape_samples_.+"
  action: "drop"
EOF
)"
```


## References
- [Dropping metrics at scrape time with Prometheus](https://www.robustperception.io/dropping-metrics-at-scrape-time-with-prometheus/) (robustperception, 2015)
- [How relabeling in Prometheus works](https://grafana.com/blog/2022/03/21/how-relabeling-in-prometheus-works/) (grafana.com, 2022)
- [How to drop and delete metrics in Prometheus](https://tanmay-bhat.github.io/posts/how-to-drop-and-delete-metrics-in-prometheus/) (gh:tanmay-bhat, 2022)
- Playgrounds:
  - https://demo.promlens.com/
  - https://relabeler.promlabs.com/

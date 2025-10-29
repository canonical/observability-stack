# Upgrade instructions

## COS 2

### Migrate from COS Lite 1 to COS 2

The main differences between COS Lite and COS from data perspective 
are that COS uses different charms for the logs and metrics backends.
For metrics, [Prometheus](https://charmhub.io/prometheus-k8s) is replaced with [distributed Mimir](https://charmhub.io/mimir-coordinator-k8s). For logs, monolithic 
[Loki](https://charmhub.io/loki-k8s) is replaced with [distributed Loki](https://charmhub.io/loki-coordinator-k8s).

Migrating data from Prometheus to Mimir or from one charm revision of 
Loki to another is complex and nuanced. At this point, we recommend a 
retention-based phase-out.

#### Migration via retention-based phase-out

1. Deploy COS in a separate model next to COS Lite
2. Relate the new COS charms to the same applications COS Lite is related to.
3. Wait for the retention period to elapse for COS Lite.
4. Verify the same data is available both in COS Lite and in COS
5. Decommission COS Lite.

### Migrate from COS Lite 1 to COS Lite 2
1. Refresh all track 1 charms so they point to the latest revision on `1/stable`.
2. Refresh to track 2.

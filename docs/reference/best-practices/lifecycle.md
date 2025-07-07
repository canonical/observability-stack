# Lifecycle Best Practices

## Support window
Refer to [Supported tracks](../supported-tracks) to choose the right track for your needs.
Note that different tracks may have different ubuntu bases or minimum Juju version requirement.

## Certificate rotation
Use blackbox-exporter to [monitor TLS certificates validity](https://discourse.charmhub.io/t/blackbox-exporter-k8s-docs-monitoring-ssl-certificates/15357).

## Maintenance
Before restarting a Kubernetes node with COS Lite applications on it, you should cordon and drain it so that the StatefulSets are moved to another node.
This process will ensure the least amount of downtime.

In the event that a node goes down unexpectedly and cannot be recovered, you can manually recover the COS Lite units by force deleting the pod and any
volume attachments that existed on the inaccessible node. The pods will then be rescheduled to a working node.


### Known issues
- High availability during maintenance is only possible on clusters utilizing distributed storage, such as MicroCeph.
- All of the COS Lite applications use StatefulSets, so these pods will not self-heal and deploy to another node automatically.
- The juju controller needs to be up for the pods to start, otherwise their charm container will fail, causing the pod to go into a crash loop.


## Upgrading
Remember to `juju refresh` with `--trust`. If omitted, you would need to `juju trust X --scope=cluster`.

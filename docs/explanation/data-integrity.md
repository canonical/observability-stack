---
myst:
 html_meta:
  description: "Understand data integrity in COS Lite, which is addressed in Ceph. COS and COS Lite charms don't need additional configuration."
---

# Data Integrity

COS and COS Lite rely on Kubernetes persistent volumes (PVs) for data persistency. COS charms also rely on S3 storage.

The data replication factor in both PVs and S3 is addressed in the storage backend (e.g. Ceph). No additional replication configuration is available in COS or COS Lite charms themselves.

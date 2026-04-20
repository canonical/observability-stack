---
myst:
 html_meta:
   description: "Configure the underlying storage of the Observability stack components."
---

# How to configure Juju storage directives with Terraform

The COS Terraform modules allow configuring the [storage directives](https://documentation.ubuntu.com/juju/3.6/reference/storage/#storage-directive) of their components. To know which Juju storages exist for a component, refer to its `charmcraft.yaml` file in its source code.

```{literalinclude} /how-to/deploy-and-manage/cos-storage.tf
```

Note that the default for each storage directive is set to 1 GB. For detailed information regarding storage sizing, see the [Storage best practices](/reference/storage.md) reference.

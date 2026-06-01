---
myst:
 html_meta:
   description: "Configure the Juju model deployed as the base of the Canonical Observability Stack (COS), including the model name, cloud, and Juju model settings."
---

# How to configure the Juju model of COS

The COS Lite Terraform module creates a Juju model named `cos-lite` by default. Use the `model` variable to customize the configuration of the default model, or target an existing model with a UUID.

## Set a custom model name and configuration

Set the `model` variable with the desired name and any [Juju model configuration](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/model), for example:

```hcl
module "cos_lite" {
  source = "git::https://github.com/canonical/observability-stack.git//terraform/cos-lite"

  model = {
    name = "cos-lite-production"
    config = {
      logging-config = "<root>=WARNING; unit=DEBUG"
    }
  }
}
```

## Deploy into an existing model

To deploy COS into a model that already exists, provide its UUID via `model.uuid`:

```hcl
module "cos_lite" {
  source = "git::https://github.com/canonical/observability-stack.git//terraform/cos-lite"

  model = {
    uuid = "82d8c989-3087-416b-8ff2-d94ede266035"
  }
}
```

To retrieve the UUID of an existing model, run:

```bash
juju show-model <model-name> --format=json | jq '.[].model-uuid'
```

```{warning}
The Juju Terraform provider translates state changes into Juju API calls. There is no guarantee that arbitrary state transitions, such as switching between a module-managed model and a pre-existing one, will converge without manual intervention.
```

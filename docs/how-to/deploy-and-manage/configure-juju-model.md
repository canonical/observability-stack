---
myst:
 html_meta:
   description: "Configure the Juju model deployed as the base of the Canonical Observability Stack (COS), including the model name, cloud, and Juju model settings."
---

# How to configure the Juju model of COS

The COS Terraform module creates a Juju model named `cos` by default. Use the `model` variable to customize the configuration of the module-managed model, or target an existing model with a UUID.

## Set a custom model name and configuration

Set the `model` variable with the desired name and any [Juju model configuration](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/model), for example:

```hcl
module "cos" {
  source = "git::https://github.com/canonical/observability-stack.git//terraform/cos"

  model = {
    name = "cos-production"
    config = {
      logging-config = "<root>=WARNING; unit=DEBUG"
    }
  }
}
```

After deploying COS, you may want to update the module-managed model's configuration. Just update the model's `config` and apply. Review the [common configuration mistakes](#common-configuration-mistakes) before continuing.

## Deploy into an existing model

To deploy COS into a model that already exists, provide its UUID via `model.uuid`:

```hcl
module "cos" {
  source = "git::https://github.com/canonical/observability-stack.git//terraform/cos"

  model = {
    uuid = "82d8c989-3087-416b-8ff2-d94ede266035"
  }
}
```

To retrieve the UUID of an existing model, run:

```bash
juju models --format json | jq -r '.models[] | select(.name | contains("my-cos-model"))["model-uuid"]'
```

## Common configuration mistakes

### Creating a model which already exists
If you set the `model.name` to the same name as an existing model, then Juju returns a client error because it cannot create the model:

```bash
module.cos.juju_model.cos[0]: Creating...
╷
│ Error: Client Error
│ 
│   with module.cos.juju_model.cos[0],
│   on .terraform/modules/cos/terraform/cos/model.tf line 3, in resource "juju_model" "cos":
│    3: resource "juju_model" "cos" {
│ 
│ Unable to create model "\"my-cos-model\"", got error: failed to open kubernetes client: annotations map[controller.juju.is/id:7c1aed20-86bf-4853-8609-62a08f25bca6 model.juju.is/id:82d8c989-3087-416b-8ff2-d94ede266035] for namespace "my-cos-model"
│ not valid must include map[controller.juju.is/id:7c1aed20-86bf-4853-8609-62a08f25bca6 model.juju.is/id:2c0550ed-7129-47bb-884b-1234f56f308b] (not valid)
```

Choose a new model name or remove the existing one to proceed.

### Switching Juju models post-deployment

The Juju Terraform provider translates state changes into Juju API calls. There is no guarantee that arbitrary state transitions, such as:
- switching between a module-managed model and a pre-existing one
- changing the name of the module-managed model
- updating the `model.uuid`

will converge without manual intervention. Think of it as "would I do this with the Juju CLI?" if not, then doing this with Terraform should be conducted in a staging or dev environment and not attempted in a production-like environment.

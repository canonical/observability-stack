# Terraform module for COS solution

This is a Terraform module facilitating the deployment of COS solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs). This Terraform module deploys COS with Mimir, Tempo and Loki in their microservices modes, and other charms in monolithic mode.

> [!NOTE]
> `s3-integrator` itself doesn't act as an S3 object storage system. For the HA solution to be functional, `s3-integrator` needs to point to an S3-like storage. See [this guide](https://discourse.charmhub.io/t/cos-lite-docs-set-up-minio/15211) to learn how to connect to an S3-like storage for traces.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 0.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 0.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alertmanager"></a> [alertmanager](#module\_alertmanager) | git::https://github.com/canonical/alertmanager-k8s-operator//terraform | n/a |
| <a name="module_catalogue"></a> [catalogue](#module\_catalogue) | git::https://github.com/canonical/catalogue-k8s-operator//terraform | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | git::https://github.com/canonical/grafana-k8s-operator//terraform | n/a |
| <a name="module_loki"></a> [loki](#module\_loki) | git::https://github.com/canonical/observability-stack//terraform/loki | n/a |
| <a name="module_mimir"></a> [mimir](#module\_mimir) | git::https://github.com/canonical/observability-stack//terraform/mimir | n/a |
| <a name="module_opentelemetry_collector"></a> [opentelemetry\_collector](#module\_opentelemetry\_collector) | git::https://github.com/canonical/opentelemetry-collector-k8s-operator//terraform | n/a |
| <a name="module_ssc"></a> [ssc](#module\_ssc) | git::https://github.com/canonical/self-signed-certificates-operator//terraform | n/a |
| <a name="module_tempo"></a> [tempo](#module\_tempo) | git::https://github.com/canonical/observability-stack//terraform/tempo | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | git::https://github.com/canonical/traefik-k8s-operator//terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager"></a> [alertmanager](#input\_alertmanager) | Application configuration for Alertmanager. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "alertmanager")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity constraints across all HA modules (Mimir, Loki, Tempo) | `bool` | `true` | no |
| <a name="input_catalogue"></a> [catalogue](#input\_catalogue) | Application configuration for Catalogue. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "catalogue")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the applications are (unless overwritten by external\_channels) deployed from | `string` | n/a | yes |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | Kubernetes cloud or environment where this COS module will be deployed (e.g self-managed, aws) | `string` | `"self-managed"` | no |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates | `string` | `null` | no |
| <a name="input_grafana"></a> [grafana](#input\_grafana) | Application configuration for Grafana. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "grafana")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki_bucket"></a> [loki\_bucket](#input\_loki\_bucket) | Loki bucket name | `string` | n/a | yes |
| <a name="input_loki_coordinator"></a> [loki\_coordinator](#input\_loki\_coordinator) | Application configuration for Loki Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_loki_worker"></a> [loki\_worker](#input\_loki\_worker) | Application configuration for all Loki Workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    backend_config     = optional(map(string), {})<br/>    read_config        = optional(map(string), {})<br/>    write_config       = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    backend_units      = optional(number, 3)<br/>    read_units         = optional(number, 3)<br/>    write_units        = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_mimir_bucket"></a> [mimir\_bucket](#input\_mimir\_bucket) | Mimir bucket name | `string` | n/a | yes |
| <a name="input_mimir_coordinator"></a> [mimir\_coordinator](#input\_mimir\_coordinator) | Application configuration for Mimir Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_mimir_worker"></a> [mimir\_worker](#input\_mimir\_worker) | Application configuration for all Mimir Workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    backend_config     = optional(map(string), {})<br/>    read_config        = optional(map(string), {})<br/>    write_config       = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    backend_units      = optional(number, 3)<br/>    read_units         = optional(number, 3)<br/>    write_units        = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_opentelemetry_colector"></a> [opentelemetry\_colector](#input\_opentelemetry\_colector) | Application configuration for OpenTelemetry Collector. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "otelcol")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential | `string` | n/a | yes |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint | `string` | n/a | yes |
| <a name="input_s3_integrator"></a> [s3\_integrator](#input\_s3\_integrator) | Application configuration for all S3-integrators in coordinated workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    channel            = optional(string, "2/edge")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, 157) # FIXME: https://github.com/canonical/observability/issues/342<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential | `string` | n/a | yes |
| <a name="input_ssc"></a> [ssc](#input\_ssc) | Application configuration for Self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "ca")<br/>    channel            = optional(string, "1/stable")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_tempo_bucket"></a> [tempo\_bucket](#input\_tempo\_bucket) | Tempo bucket name | `string` | n/a | yes |
| <a name="input_tempo_coordinator"></a> [tempo\_coordinator](#input\_tempo\_coordinator) | Application configuration for Tempo Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_tempo_worker"></a> [tempo\_worker](#input\_tempo\_worker) | Application configuration for all Tempo workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    querier_config           = optional(map(string), {})<br/>    query_frontend_config    = optional(map(string), {})<br/>    ingester_config          = optional(map(string), {})<br/>    distributor_config       = optional(map(string), {})<br/>    compactor_config         = optional(map(string), {})<br/>    metrics_generator_config = optional(map(string), {})<br/>    constraints              = optional(string, "arch=amd64")<br/>    revision                 = optional(number, null)<br/>    storage_directives       = optional(map(string), {})<br/>    compactor_units          = optional(number, 3)<br/>    distributor_units        = optional(number, 3)<br/>    ingester_units           = optional(number, 3)<br/>    metrics_generator_units  = optional(number, 3)<br/>    querier_units            = optional(number, 3)<br/>    query_frontend_units     = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_traefik"></a> [traefik](#input\_traefik) | Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "traefik")<br/>    channel            = optional(string, "latest/stable")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_offers"></a> [offers](#output\_offers) | All Juju offers which are exposed by this product module |
<!-- END_TF_DOCS -->

## Usage


### Basic usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run `terraform apply -var="model=<MODEL_NAME>" -auto-approve`. This would deploy all COS HA solution modules in the same model.

#### Known Juju issue.

Because this [Juju issue](https://github.com/juju/juju/issues/20210) a message like this one can be seen after running `terraform apply`:

```
╷
│ Error: Client Error
│ 
│   with module.cos.module.mimir.juju_secret.mimir_s3_credentials_secret,
│   on /home/mt/work/canonical/repos/observability/terraform/modules/mimir/main.tf line 1, in resource "juju_secret" "mimir_s3_credentials_secret":
│    1: resource "juju_secret" "mimir_s3_credentials_secret" {
│ 
│ Unable to add secret, got error: rolebindings.rbac.authorization.k8s.io "model-cos"
│ already exists
╵
```

Until this issue is solved, a workaround to this is to retry a `terraform apply`.


### High Availability

By default, this Terraform module will deploy each worker with `3` unit. If you want to scale each Loki, Mimir or Tempo worker unit please check the variables available for that purpose in `variables.tf`.

### Minimal sample deployment.

In order to deploy COS create a `main.tf` file with the following content:

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# COS module that deploy the whole Canonical Observability Stack
module "cos" {
    source                        = "git::https://github.com/canonical/observability-stack//terraform/cos"
    model                         = "cos"
    channel                       = "1/stable"
    cloud                         = "self-managed"
    s3_endpoint                   = "http://S3_HOST_IP:8080"
    s3_secret_key                 = "secret-key"
    s3_access_key                 = "access-key"
    loki_bucket                   = "loki"
    mimir_bucket                  = "mimir"
    tempo_bucket                  = "tempo"
}
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```

Some minutes after running these two commands, we have a distributed COS deployment!

```shell
$ juju status --relations
Model  Controller  Cloud/Region        Version  SLA          Timestamp
cos    microk8s    microk8s/localhost  3.6.2    unsupported  20:16:42-03:00

App                       Version  Status  Scale  Charm                     Channel      Rev  Address         Exposed  Message
alertmanager              0.27.0   active      1  alertmanager-k8s          latest/edge  156  10.152.183.57   no
catalogue                          active      1  catalogue-k8s             latest/edge   81  10.152.183.88   no
grafana                   9.5.3    active      1  grafana-k8s               latest/edge  141  10.152.183.138  no
grafana-agent             0.40.4   active      1  grafana-agent-k8s         latest/edge  112  10.152.183.37   no       grafana-dashboards-provider: off
loki                               active      3  loki-coordinator-k8s      latest/edge   20  10.152.183.201  no
loki-backend              3.0.0    active      3  loki-worker-k8s           latest/edge   34  10.152.183.112  no       backend ready.
loki-read                 3.0.0    active      3  loki-worker-k8s           latest/edge   34  10.152.183.87   no       read ready.
loki-s3-integrator                 active      1  s3-integrator             latest/edge  139  10.152.183.20   no
loki-write                3.0.0    active      3  loki-worker-k8s           latest/edge   34  10.152.183.167  no       write ready.
mimir                              active      3  mimir-coordinator-k8s     latest/edge   38  10.152.183.207  no
mimir-backend             2.13.0   active      3  mimir-worker-k8s          latest/edge   45  10.152.183.45   no       backend ready.
mimir-read                2.13.0   active      3  mimir-worker-k8s          latest/edge   45  10.152.183.160  no       read ready.
mimir-s3-integrator                active      1  s3-integrator             latest/edge  139  10.152.183.85   no
mimir-write               2.13.0   active      3  mimir-worker-k8s          latest/edge   45  10.152.183.125  no       write ready.
self-signed-certificates           active      1  self-signed-certificates  1/edge       268  10.152.183.34   no
tempo                              active      3  tempo-coordinator-k8s     latest/edge   70  10.152.183.72   no
tempo-compactor           2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.99   no       compactor ready.
tempo-distributor         2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.162  no       distributor ready.
tempo-ingester            2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.195  no       ingester ready.
tempo-metrics-generator   2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.122  no       metrics-generator ready.
tempo-querier             2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.136  no       querier ready.
tempo-query-frontend      2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.105  no       query-frontend ready.
tempo-s3-integrator                active      1  s3-integrator             latest/edge  139  10.152.183.121  no
traefik                   2.11.0   active      1  traefik-k8s               latest/edge  234  10.152.183.110  no       Serving at 192.168.1.244

Unit                         Workload  Agent  Address       Ports  Message
alertmanager/0*              active    idle   10.1.167.134
catalogue/0*                 active    idle   10.1.167.150
grafana-agent/0*             active    idle   10.1.167.149         grafana-dashboards-provider: off
grafana/0*                   active    idle   10.1.167.173
loki-backend/0*              active    idle   10.1.167.148         backend ready.
loki-backend/1               active    idle   10.1.167.171         backend ready.
loki-backend/2               active    idle   10.1.167.188         backend ready.
loki-read/0                  active    idle   10.1.167.153         read ready.
loki-read/1                  active    idle   10.1.167.180         read ready.
loki-read/2*                 active    idle   10.1.167.183         read ready.
loki-s3-integrator/0*        active    idle   10.1.167.169
loki-write/0*                active    idle   10.1.167.144         write ready.
loki-write/1                 active    idle   10.1.167.142         write ready.
loki-write/2                 active    idle   10.1.167.187         write ready.
loki/0*                      active    idle   10.1.167.174
mimir-backend/0*             active    idle   10.1.167.139         backend ready.
mimir-backend/1              active    idle   10.1.167.128         backend ready.
mimir-backend/2              active    idle   10.1.167.177         backend ready.
mimir-read/0*                active    idle   10.1.167.151         read ready.
mimir-read/1                 active    idle   10.1.167.163         read ready.
mimir-read/2                 active    idle   10.1.167.132         read ready.
mimir-s3-integrator/0*       active    idle   10.1.167.137
mimir-write/0*               active    idle   10.1.167.152         write ready.
mimir-write/1                active    idle   10.1.167.167         write ready.
mimir-write/2                active    idle   10.1.167.143         write ready.
mimir/0*                     active    idle   10.1.167.135
self-signed-certificates/0*  active    idle   10.1.167.166
tempo-compactor/0            active    idle   10.1.167.181         compactor ready.
tempo-compactor/1*           active    idle   10.1.167.168         compactor ready.
tempo-compactor/2            active    idle   10.1.167.129         compactor ready.
tempo-distributor/0*         active    idle   10.1.167.157         distributor ready.
tempo-distributor/1          active    idle   10.1.167.131         distributor ready.
tempo-distributor/2          active    idle   10.1.167.186         distributor ready.
tempo-ingester/0*            active    idle   10.1.167.191         ingester ready.
tempo-ingester/1             active    idle   10.1.167.133         ingester ready.
tempo-ingester/2             active    idle   10.1.167.179         ingester ready.
tempo-metrics-generator/0*   active    idle   10.1.167.147         metrics-generator ready.
tempo-metrics-generator/1    active    idle   10.1.167.159         metrics-generator ready.
tempo-metrics-generator/2    active    idle   10.1.167.146         metrics-generator ready.
tempo-querier/0              active    idle   10.1.167.170         querier ready.
tempo-querier/1              active    idle   10.1.167.140         querier ready.
tempo-querier/2*             active    idle   10.1.167.165         querier ready.
tempo-query-frontend/0*      active    idle   10.1.167.162         query-frontend ready.
tempo-query-frontend/1       active    idle   10.1.167.190         query-frontend ready.
tempo-query-frontend/2       active    idle   10.1.167.184         query-frontend ready.
tempo-s3-integrator/0*       active    idle   10.1.167.172
tempo/0*                     active    idle   10.1.167.189
traefik/0*                   active    idle   10.1.167.182         Serving at 192.168.1.244

Integration provider                     Requirer                                 Interface                Type     Message
alertmanager:alerting                    loki:alertmanager                        alertmanager_dispatch    regular
alertmanager:alerting                    mimir:alertmanager                       alertmanager_dispatch    regular
alertmanager:grafana-dashboard           grafana:grafana-dashboard                grafana_dashboard        regular
alertmanager:grafana-source              grafana:grafana-source                   grafana_datasource       regular
alertmanager:replicas                    alertmanager:replicas                    alertmanager_replica     peer
alertmanager:self-metrics-endpoint       grafana-agent:metrics-endpoint           prometheus_scrape        regular
catalogue:catalogue                      alertmanager:catalogue                   catalogue                regular
catalogue:catalogue                      grafana:catalogue                        catalogue                regular
catalogue:catalogue                      mimir:catalogue                          catalogue                regular
catalogue:catalogue                      tempo:catalogue                          catalogue                regular
catalogue:replicas                       catalogue:replicas                       catalogue_replica        peer
grafana-agent:logging-provider           loki:logging-consumer                    loki_push_api            regular
grafana-agent:logging-provider           tempo:logging                            loki_push_api            regular
grafana-agent:peers                      grafana-agent:peers                      grafana_agent_replica    peer
grafana-agent:tracing-provider           grafana:charm-tracing                    tracing                  regular
grafana-agent:tracing-provider           loki:charm-tracing                       tracing                  regular
grafana-agent:tracing-provider           mimir:charm-tracing                      tracing                  regular
grafana:grafana                          grafana:grafana                          grafana_peers            peer
grafana:replicas                         grafana:replicas                         grafana_replicas         peer
loki-s3-integrator:s3-credentials        loki:s3                                  s3                       regular
loki-s3-integrator:s3-integrator-peers   loki-s3-integrator:s3-integrator-peers   s3-integrator-peers      peer
loki:grafana-dashboards-provider         grafana:grafana-dashboard                grafana_dashboard        regular
loki:grafana-source                      grafana:grafana-source                   grafana_datasource       regular
loki:logging                             grafana-agent:logging-consumer           loki_push_api            regular
loki:loki-cluster                        loki-backend:loki-cluster                loki_cluster             regular
loki:loki-cluster                        loki-read:loki-cluster                   loki_cluster             regular
loki:loki-cluster                        loki-write:loki-cluster                  loki_cluster             regular
loki:self-metrics-endpoint               grafana-agent:metrics-endpoint           prometheus_scrape        regular
mimir-s3-integrator:s3-credentials       mimir:s3                                 s3                       regular
mimir-s3-integrator:s3-integrator-peers  mimir-s3-integrator:s3-integrator-peers  s3-integrator-peers      peer
mimir:grafana-dashboards-provider        grafana:grafana-dashboard                grafana_dashboard        regular
mimir:grafana-source                     grafana:grafana-source                   grafana_datasource       regular
mimir:mimir-cluster                      mimir-backend:mimir-cluster              mimir_cluster            regular
mimir:mimir-cluster                      mimir-read:mimir-cluster                 mimir_cluster            regular
mimir:mimir-cluster                      mimir-write:mimir-cluster                mimir_cluster            regular
mimir:receive-remote-write               grafana-agent:send-remote-write          prometheus_remote_write  regular
mimir:receive-remote-write               tempo:send-remote-write                  prometheus_remote_write  regular
mimir:self-metrics-endpoint              grafana-agent:metrics-endpoint           prometheus_scrape        regular
tempo-s3-integrator:s3-credentials       tempo:s3                                 s3                       regular
tempo-s3-integrator:s3-integrator-peers  tempo-s3-integrator:s3-integrator-peers  s3-integrator-peers      peer
tempo:grafana-source                     grafana:grafana-source                   grafana_datasource       regular
tempo:metrics-endpoint                   grafana-agent:metrics-endpoint           prometheus_scrape        regular
tempo:peers                              tempo:peers                              tempo_peers              peer
tempo:tempo-cluster                      tempo-compactor:tempo-cluster            tempo_cluster            regular
tempo:tempo-cluster                      tempo-distributor:tempo-cluster          tempo_cluster            regular
tempo:tempo-cluster                      tempo-ingester:tempo-cluster             tempo_cluster            regular
tempo:tempo-cluster                      tempo-metrics-generator:tempo-cluster    tempo_cluster            regular
tempo:tempo-cluster                      tempo-querier:tempo-cluster              tempo_cluster            regular
tempo:tempo-cluster                      tempo-query-frontend:tempo-cluster       tempo_cluster            regular
tempo:tracing                            grafana-agent:tracing                    tracing                  regular
traefik:ingress                          alertmanager:ingress                     ingress                  regular
traefik:ingress                          catalogue:ingress                        ingress                  regular
traefik:ingress                          loki:ingress                             ingress                  regular
traefik:ingress                          mimir:ingress                            ingress                  regular
traefik:peers                            traefik:peers                            traefik_peers            peer
traefik:traefik-route                    grafana:ingress                          traefik_route            regular
traefik:traefik-route                    tempo:ingress                            traefik_route            regular
```

### Deploy COS on AWS EKS

> **Note:** This deployment assumes that the required AWS infrastructure is already provisioned and that a Juju controller has been bootstrapped.  
> Additionally, a Juju model must be ready in advance.
> 
> See [provision AWS infrastructure](../aws-infra/README.md)

In order to deploy COS on AWS, create a `main.tf` file with the following content.

```hcl
# COS module that deploy the whole Canonical Observability Stack
module "cos" {
  source        = "git::https://github.com/canonical/observability-stack//terraform/cos"
  model         = "cos"
  channel       = "1/stable"
  cloud         = "aws"
  s3_endpoint   = "http://S3_HOST_IP:8080"
  s3_secret_key = "secret-key"
  s3_access_key = "access-key"
  loki_bucket   = "loki"
  mimir_bucket  = "mimir"
  tempo_bucket  = "tempo"
}
```

Then, use terraform to deploy the module:
```bash
terraform init
terraform apply
```

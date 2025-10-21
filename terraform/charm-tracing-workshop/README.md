# Getting Started with Charm Tracing

This README is a quick-start guide that shows how to deploy a minimal tracing setup and view your charm’s traces in action.

## Prerequisites

On your machine, make sure you have the following prerequisites met:

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >= v1.5
- [Juju](https://snapcraft.io/juju) >= 3.6.0
- [Charmcraft](https://snapcraft.io/charmcraft) >= 3
- A bootsrapped K8s Juju controller

## Add a COS model
This is the juju K8s model where the testing tracing setup will be deployed

`juju add-model cos`

## Deploy a testing tracing setup
In this directory, use terraform to deploy the module:
```bash
terraform init
terraform apply
```
Then, wait until everything settles down and all charms are in active/idle.

## Instrument your charm with ops[tracing]
TODO

## Deploy & Integrate your charm with Tempo
After instrumenting your charm, pack and deploy it:
```bash
cd <charm-path>
charmcraft pack
juju deploy <charm-path> $(yq eval '.resources | to_entries | map("--resource \(.key)=\(.value.upstream-source)") | .[]' charmcraft.yaml)
```

Then, if it's a K8s charm, integrate it directly with Tempo
```bash
juju integrate <your-charm-app-name>:charm-tracing tempo
```
Or else if it's a machine charm:

1. In your machine model, deploy an otel collector

```bash
juju deploy opentelemetry-collector otelcol
```

2. Integrate your charm with otel collector over `cos-agent`
```bash
juju integrate <your-charm-app-name> otelcol:cos-agent
```

3. cmr otel collector with Tempo
In your K8s model:

```bash
juju offer tempo:tracing
```

In your machine model:
```bash
juju consume admin/cos.tracing
juju integrate tracing otelcol:send-charm-traces
```
## See your charm traces in action

To open Grafana's UI, you can:
```bash
juju run grafana/0 get-admin-password
```
That should provide you with grafana's ingressed url that you can open from your browser + an initial admin password that you can use to login.

```
username: admin
password: <whatever was outputted from the juju action>
```

Then, go to `Toggle Menu` → `Explore` → select `Tempo` datasource → Add filters to view traces from your charm → `Run query`

Now, all what's left is to inspect your spans and look for potentials bottlenecks! 🔍

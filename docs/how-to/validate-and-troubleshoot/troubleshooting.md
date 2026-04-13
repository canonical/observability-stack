---
myst:
 html_meta:
   description: "Diagnose and fix common Canonical Observability Stack issues, including integrations, Grafana access, OpenTelemetry Collector errors, and alert rules."
---

# Troubleshooting

## Ceph unhealthy
If using (micro)ceph for storage, is it healthy?

| Check                | Output                                                                                       | Potential cause                                                                | Remediation                                                                                                                     |
| -------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `ceph health detail` | `HEALTH_WARN There are daemons running an older version of ceph; Reduced data availability:` | Some OSDs restarted and were running a newer version than the rest of the OSDs | Restart the other OSDs using the command for your deployment: classic Ceph: `systemctl restart ceph-osd@<id>`; MicroCeph: restart the corresponding MicroCeph snap service for the affected OSD(s). |


## `Gateway address unavailable`

Whenever Traefik is used to ingress your Kubernetes workloads, you might in some specific
cases encounter a "Gateway Address Unavailable" message. In this article, we'll go through 
what you can do to remediate it.

```{caution}
In this article, we will assume that you are running MicroK8s on either a bare-metal 
or virtual machine. If your setup differs from this, parts of the how-to may still 
apply, although you will need to tailor the exact steps and commands to your setup.
```

### Checklist

- You have run `juju trust traefik --scope=cluster`
- The [MetalLB MicroK8s add-on](https://canonical.com/microk8s/docs/addon-metallb) is enabled.
- Traefik's service type is ``LoadBalancer``.
- An external IP address is assigned to Traefik.

### Possible causes

#### The MetalLB add-on isn't enabled

Check with:

```bash 
$ microk8s status -a metallb
```

If it is disabled, you can enable it with:

```bash 
$ IPADDR=$(ip -4 -j route get 2.2.2.2 | jq -r '.[] | .prefsrc')
$ microk8s enable metallb:$IPADDR-$IPADDR
```

This command will fetch the IPv4 address assigned to your host, and hand it to MetalLB 
as an assignable IP. If the address range you want to hand to MetalLB differs from your 
host IP, alter the `$IPADDR` variable to instead specify the range you want to assign, 
for instance `IPADDR=10.0.0.1-10.0.0.100`.

#### No external IP address is assigned to the Traefik service

Does the Traefik service have an external IP assigned to it? Check with:

```bash
$ JUJU_APP_NAME="traefik"
$ kubectl get svc -A -o wide | grep -E "^NAMESPACE|$JUJU_APP_NAME"
```

#### No available IP in address pool

This can happen when: 
- MetalLB has only one IP in its range but you deployed two instances of Traefik, 
  or when Traefik is forcefully removed (`--force --no-wait`) and a new Traefik 
  app is deployed immediately after.
- The [ingress](https://canonical.com/microk8s/docs/ingress) add-on is enabled. It's possible
  that Nginx from the ingress add-on has claimed the `ExternalIP`. Disable Nginx and 
  re-enable MetalLB.

Check with:

```bash
$ kubectl get ipaddresspool -n metallb-system -o yaml && kubectl get all -n metallb-system
```

You could add more IPs to the range:

```bash
$ FROM_IP="..." TO_IP="..."
$ microk8s enable metallb:$FROM_IP-$TO_IP
```

#### The Load Balancer service type reverted to `ClusterIP`

Juju controller cycling may cause the type to revert from `LoadBalancer` back to 
`ClusterIP`. 

Check with:

```bash
$ kubectl get svc -A -o wide | grep -E "^NAMESPACE|LoadBalancer"
```

If Traefik isn't listed (it's not `LoadBalancer`), then recreate the pod to have it 
re-trigger the assignment of the external IP with `kubectl delete` . It should be `LoadBalancer` 
when Kubernetes brings it back.

#### Integration tests pass locally but fail on GitHub runners

This used to happen when the github runners were at peak usage, making the already small 2cpu7gb 
runners run even slower. As much of a bad answer as this is, the best response may be to increase 
timeouts or try to move CI jobs to internal runners.

### Verification

Verify that the Traefik Kubernetes service now has been assigned an external IP:

```

$ microk8s.kubectl get services -A

NAMESPACE         NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP                 PORT(S)
cos               traefik                  LoadBalancer   10.152.183.130   10.70.43.245                80:32343/TCP,443:30698/TCP   4d3h
                                                                            👆 - This one!
```

Verify that Traefik is functioning correctly by trying to trigger one of your ingress paths. 
If you have COS Lite deployed, you may check that if works as expected using the Catalogue charm:

```bash 
# curl http://<TRAEFIKS_EXTERNAL_IP>/<YOUR_MODEL_NAME>-catalogue/
# for example...
$ curl http://10.70.43.245/cos-catalogue/
```

This command should return a long HTML code block if everything works as expected.


## Grafana admin password

Compare the output of:

- Charm action: `juju run graf/0 get-admin-password`
- Pebble plan: `juju ssh --container grafana graf/0 /charm/bin/pebble plan | grep GF_SECURITY_ADMIN_PASSWORD`
- Secret content: Obtain secret id from `juju secrets` and then `juju show-secret d6buvufmp25c7am9qqtg --reveal`

All 3 should be identical. If they are not identical,

1. Manually [reset the admin password](https://grafana.com/docs/grafana/latest/administration/cli/#reset-admin-password),
   `juju ssh --container grafana graf/0 grafana cli --config /etc/grafana/grafana-config.ini admin reset-admin-password pa55w0rd`
2. Update the secret with the same: `juju update-secret d6buvufmp25c7am9qqtg password=pa55w0rd`
3. Run the action so the charm updates the pebble service environment variable: `juju run graf/0 get-admin-password`


## Integrations

Integrating a charm with [COS](https://charmhub.io/topics/canonical-observability-stack) means:

- having your app's metrics and corresponding alert rules reach [Prometheus](https://charmhub.io/prometheus-k8s/).
- having your app's logs and corresponding alert rules reach [Loki](https://charmhub.io/loki-k8s/).
- having your app's dashboards reach [grafana](https://charmhub.io/grafana-k8s/).

The COS team is responsible for some aspects of testing, and some aspects of testing belong to 
the charms integrating with COS.

### Tests for the built-in alert rules

#### Unit tests

You can use:

- `promtool test rules` (see details [here](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/))
  to make sure they fire when you expect them to fire. As part of the test you hard-code the time 
  series values you are testing for.
- `promtool check rules` (see details [here](https://prometheus.io/docs/prometheus/latest/command-line/promtool/#promtool-check))
  to make sure the rules have valid syntax. 
- `cos-tool validate` (see details [here](https://github.com/canonical/cos-tool)). The advantage of 
  cos-tool is that the same executable can validate both Prometheus and Loki rules.

Make sure your alerts manifest matches the output of:

```bash
$ juju ssh prometheus/0 curl localhost:9090/api/v1/rules | jq -r '.data.groups | .[] | .rules | .[] | .name'
# and...
$ juju ssh loki/0 curl localhost:3100/loki/api/v1/rules
```

#### Integration tests

```{note}
A fresh deployment shouldn't fire alerts. This can happen when the alert rules are not taking into account
that there is no prior data, thus interpreting it as `0`.
```

### Tests for the metrics endpoint and scrape job

#### Integration tests

- `promtool check metrics` (see details [here](https://prometheus.io/docs/prometheus/latest/command-line/promtool/#promtool-check)) to lint the the metrics endpoint,
  e.g.
  ```  
  curl -s http://localhost:8080/metrics | promtool check metrics`.
  ```
- For scrape targets: when related to prometheus, and after a scrape interval elapses (default: `1m`), all 
  prometheus targets listed in `GET /api/v1/targets` should be `"health": "up"`. Repeat the test with/without
  ingress and TLS.
- For remote-write (and scrape targets): when related to prometheus, make sure that `GET /api/v1/labels` 
  and `GET /api/v1/label/juju_unit` have your charm listed.
- Make sure that the metric names in your alert rules have matching metrics in your own `/metrics` endpoint.

### Tests for log lines

#### Integration tests

When related to Loki, make sure your logging sources are listed in:
  - `GET /loki/api/v1/label/filename/values`
  - `GET /loki/api/v1/label/juju_unit/values`

### Tests for dashboards

#### Unit tests

* JSON linting

#### Integration tests

Make sure the dashboards manifest you have in the charm matches:

```bash
$ juju ssh grafana/0 curl http://admin:password@localhost:3000/api/search
```

### Data Duplication

#### Multiple grafana-agent apps related to the same principle

Charms should use `limit: 1` for the cos-agent relation (see example [here](https://github.com/canonical/zookeeper-operator/blob/main/metadata.yaml#L31), 
but this cannot be enforced by grafana-agent itself.  You can confirm this is the case with `jq`:

```bash
$ juju export-bundle | yq -o json '.' | jq -r '
    .applications as $apps |
    .relations as $relations |
    $apps
    | to_entries
    | map(select(.value.charm == "grafana-agent")) | map(.key) as $grafana_agents |
    $apps     
    | to_entries
    | map(.key) as $valid_apps |     
    $relations                      
    | map({
        app1: (.[0] | split(":")[0]),                                                 
        app2: (.[1] | split(":")[0])                                  
      })          
    | map(select(                     
        ((.app1 | IN($grafana_agents[])) and (.app2 | IN($valid_apps[]))) or
        ((.app2 | IN($grafana_agents[])) and (.app1 | IN($valid_apps[])))
      ))
    | map(if .app1 | IN($grafana_agents[]) then .app2 else .app1 end) 
    | group_by(.) 
    | map({app: .[0], count: length}) 
    | map(select(.count > 1))
  '
```

If the same principal has more than one cos-agent relation, you would see output such as:

```json

[
  {
    "app": "openstack-exporter",
    "count": 2
  }
]
```

Otherwise, you'd get:

```bash
jq: error (at <stdin>:19): Cannot iterate over null (null)
```

(which is good).

You can achieve this also using the status YAML. Save the following script to `is_multi_agent.py`:



```python
#!/usr/bin/env python3

import yaml, sys

status = yaml.safe_load(sys.stdin.read())

# A mapping from grafana-agent app name to the list of apps it's subordiante to
agents = {
    k: v["subordinate-to"]
    for k, v in status["applications"].items()
    if v["charm"] == "grafana-agent"
}
# print(agents)

for agent, principals in agents.items():
    for p in principals:
        for name, unit in status["applications"][p].get("units", {}).items():
            subord_apps = {u.split("/", -1)[0] for u in unit["subordinates"].keys()}
            subord_agents = subord_apps & agents.keys()
            if len(subord_agents) > 1:
                print(
                    f"{name} is related to more than one grafana-agent subordinate: {subord_agents}"
                )
```

Then run it using:

```bash
$ juju status --format=yaml | ./is_multi_agent.py
```

If there is a problem, you would see output such as:

```bash    
openstack-exporter/19 is related to more than one grafana-agent subordinate: {'grafana-agent-container', 'grafana-agent-vm'}
```

### Grafana-agent related to multiple principles on the same machine

The grafana-agent machine charm can only be related to one principal in the same machine.

Save the following script to `is_multi.py`:

```python

#!/usr/bin/env python3

import yaml, sys

status = yaml.safe_load(sys.stdin.read())

# A mapping from grafana-agent app name to the list of apps it's subordiante to
agents = {
    k: v["subordinate-to"]
    for k, v in status["applications"].items()
    if v["charm"] == "grafana-agent"
}

for agent, principals in agents.items():
    # A mapping from app name to machines
    machines = {
        p: [u["machine"] for u in status["applications"][p].get("units", {}).values()]
        for p in principals
    }

    from itertools import combinations

    for p1, p2 in combinations(principals, 2):
        if overlap := set(machines[p1]) & set(machines[p2]):
            print(
                f"{agent} is subordinate to both '{p1}', '{p2}' in the same machines {overlap}"
            )
```

Then run it with:

```bash
$ juju status --format=yaml | ./is_multi.py
```

If there is a problem, you would see output such as:

```bash 
ga is subordinate to both 'co', 'nc' in the same machines {'24'}
```

### Additional thoughts
- A rock's CI could dump a record of the `/metrics` endpoint each time the rock is built. This 
  way some integration tests could turn into unit tests.

### See also

- [Troubleshooting Prometheus Integrations](https://discourse.charmhub.io/t/prometheus-k8s-docs-troubleshooting-integrations/14351)
- [Troubleshooting missing logs](https://discourse.charmhub.io/t/loki-k8s-docs-troubleshooting-missing-logs/14187)


## `No data` in Grafana panels

Data in Grafana panels is obtained by querying datasources.


### Adjust the time range
Check if there is any data when you change the 
[time range](https://grafana.com/docs/grafana-cloud/visualizations/dashboards/use-dashboards/#set-dashboard-time-range)
to `1d`, `7d`, etc.
Perhaps you had "no data" all along or it started happening only recently.


### Inspect variable values
Drop-down [variables](https://grafana.com/docs/grafana/latest/visualizations/dashboards/variables/)
could be filtering out data incorrectly.
Under dashboard settings, inspect the current values of the variables.
- If you can find a combination of dropdown selections that results in data being shown, then
  perhaps the offered variable options should be [narrowed down](https://grafana.com/docs/grafana/latest/visualizations/dashboards/variables/add-template-variables/) with a more accurate query.
- If the options listed in the dropdown are missing items you expect to be there, then the datasource might be
  missing some telemetry, or perhaps we refer to a metric that does not exist, or apply a combination of labels that does not produce a result.


### Confirm the query is valid
[Edit the panel](https://grafana.com/docs/grafana/latest/visualizations/panels-visualizations/panel-editor-overview/)
and incrementally simplify the faulty query, until data shows up.
For example,
- drop label matchers
- remove aggregation operations (`on`, `sum by`)
- replace `$__` interval macros with literals such as `5s` or `5m`
- remove drop-down variables from the query
- disable transformations or overrides that could potentially hide data

Open the query inspector panel and check the response.

If only some of the telemetry you expect to have does not exist, then perhaps a relation is missing (or duplicated).


### Check datasource connection
Test the datasource connection.
- URL correct?
- For TLS, does grafana trust the CA that signed the datasource? Perhaps there's a missing certificate-transfer relation?
- Credentials valid?
- Proxy configured? Proxy can be [configured](https://documentation.ubuntu.com/juju/latest/reference/configuration/list-of-model-configuration-keys/#model-config-http-proxy) per model.
- Datasource (backend) errors in the logs?
- Errors in grafana server logs?


### Test the query in the datasource UI
Some datasources (backends, e.g. Prometheus) have their own UI where you can paste the query
from the faulty Grafana panel. If the query works in the backend UI but not in Grafana,
check datasource connection.


### Confirm that the relevant juju relations are in place
- Grafana should be related over the [grafana-source](https://charmhub.io/integrations/grafana_datasource) relation to all relevant datasources.
- In typical deployments, telemetry is pushed from outside the model. Make sure the backends have an ingress relation.
- For deployment that are TLS-terminated, Grafana needs a `recieve-ca-cert` relation from Traefik.


### Confirm backends are not out of disk space
If a backend (e.g. Prometheus) runs out of disk space, then it will not ingest new
telemetry.


### Confirm you can curl the backend via its ingress URL
- Can grafana reach the datasource URL?
- Can grafana-agent or opentelemetry (or any other telemetry producer or aggregator) reach its backend?
  For example, can grafana-agent reach prometheus? Pay attention to http vs. https.


## OpenTelemetry Collector

### High resource usage

#### Attempting to scrape too many logs?

Inspect the list of files opened by otelcol and their size.

```bash
juju ssh ubuntu/0 "sudo lsof -nP -p $(pgrep otelcol)"
```

You should see entries such as:

```
COMMAND   PID USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
otelcol 45246 root   46r      REG                8,1  11980753    3206003 /var/log/syslog
otelcol 45246 root   12r      REG                8,1    292292    3205748 /var/log/lastlog
otelcol 45246 root   30r      REG                8,1    157412    3161673 /var/log/auth.log
otelcol 45246 root   16r      REG                8,1     96678    3195546 /var/log/juju/machine-lock.log
otelcol 45246 root   45r      REG                8,1     77200    3205894 /var/log/cloud-init.log
otelcol 45246 root   35r      REG                8,1     61211    3205745 /var/log/dpkg.log
otelcol 45246 root   25r      REG                8,1     29037    3205893 /var/log/cloud-init-output.log
otelcol 45246 root   18r      REG                8,1      6121    3205741 /var/log/apt/history.log
otelcol 45246 root   15r      REG                8,1      1941    3206035 /var/log/unattended-upgrades/unattended-upgrades.log
otelcol 45246 root   17r      REG                8,1       474    3183206 /var/log/alternatives.log
```

Compare the total size of logs to the available memory.


## `socket: too many open files`

When deploying the Grafana Agent or Prometheus charms in large environments, 
you may sometimes bump into an issue where the large amount of scrape targets 
leads to the process hitting the max open files count, as set by ``ulimit``.

This issue can be identified by looking in your Grafana Agent logs, or Prometheus 
Scrape Targets in the UI, for the following kind of message:

```
Get "http://10.0.0.1:9275/metrics": dial tcp 10.0.0.1:9275: socket: too many open files
```

To resolve this, we need to increase the max open file limit of the Kubernetes 
deployment itself. For MicroK8s, this would be done by increasing the limits in 
`/var/snap/microk8s/current/args/containerd-env`.

### 1. Juju SSH into the machine

```bash
$ juju ssh uk8s/1
```

Substitute `uk8s/1` with the name of your MicroK8s unit. If you have more than 
one unit, you will need to repeat this for each of them.

### 2. Open the ``containerd-env``

You can use whatever editor you prefer for this. In this how-to, we'll use ``vim``.

```bash
$ vim /var/snap/microk8s/current/args/containerd-env
```

### 3. Increase the `ulimit`

```diff

# Attempt to change the maximum number of open file descriptors
# this get inherited to the running containers
#
- ulimit -n 1024 || true
+ ulimit -n 65536 || true

# Attempt to change the maximum locked memory limit
# this get inherited to the running containers
#
- ulimit -l 1024 || true
+ ulimit -l 16384 || true
```

### 4. Restart the MicroK8s machine

Restart the machine the MicroK8s unit is deployed on and then wait for it to come back up.

```bash 
$ sudo reboot
```

### 5. Validate

Validate that the change made it through and had the desired effect once the machine is 
back up and running.

```bash
$ juju ssh uk8s/1 cat /var/snap/microk8s/current/args/containerd-env

[...]

# Attempt to change the maximum number of open file descriptors
# this get inherited to the running containers
#
ulimit -n 65536 || true

# Attempt to change the maximum locked memory limit
# this get inherited to the running containers
#
ulimit -l 16384 || true
```

## Firing alert rules
This guide describes how to troubleshoot firing generic alert rules. For detailed explanations on the design and goals of these rules, refer to the [explanation page](/explanation/alerting/generic-rules).

### How to troubleshoot the `HostDown` alert
The `HostDown` alert is a sign that Prometheus is unable to scrape the metrics endpoint of the charm for whom this alert is firing. The methods below can help pinpoint the issue.

#### Ensure the workload is running
It is possible that the charm being scraped by Prometheus is not running. Shell into the workload container and check the service status:

```shell
juju ssh <the rest of the commands including `pebble services`>
```

#### Ensure Prometheus is scraping the correct endpoint
It is possible that Prometheus is not scraping the correct address, endpoint, or port. When a charm is related to Prometheus for scraping of metrics, the Prometheus config file appends the related charm's metrics endpoint address and port into its list of targets. For K8s charms, this address can be the pod's FQDN or the ingress address (if using Traefik for example). If the charm being scraped does not write the address correctly, then Prometheus will be unable to reach it.

Another possibility is that the charm does not specify the correct port or endpoint for its metrics. When a charm instantiates the `MetricsEndpointProvider` object, it needs to set the correct port and metrics endpoint. For example, Alertmanager exposes its metrics at the `/metrics` endpoint on port 9093. Charm authors should ensure these values are correctly set, otherwise Prometheus may not have the correct information when attempting to scrape. Use the `ss` command to determine which ports are exposed by your workload.

#### Ensure the correct firewall and SSL/TLS configurations are applied
From inside the Prometheus container:

1. View the Prometheus configuration file located at `/etc/prometheus/prometheus.yml`

```shell
cat /etc/prometheus/prometheus.yml
```

2. Find the address of your target

3. Attempt to `curl` it from inside that container.

```shell
curl <address of your workload>
```

4. Ensure the `curl` request is successful

A failed request can be due to a firewall issue. Ensure your firewall rules allow Prometheus to reach the instance.

If your workload uses TLS communication, Prometheus needs to trust that CA that signed that workload to be able to reach it. For example, if your charm is signed through an integration to Lego, Prometheus needs to have the CA cert in its root store (through a `receive-ca-cert` relation) so it can communicate in HTTPS with your charm.

### How to troubleshoot the `AggregatorHostHealth` alerts
The `HostMetricsMissing` and `AggregatorMetricsMissing` alerts under the `AggregatorHostHealth` group are similar, with only differences in their severity and the units they are responsible for. As such, the methods to troubleshoot them are identical.
#### Confirm the aggregator is running
For machine charms, ensure the snap is running by checking its status in the machine hosting it. In this example, we'll assume that our aggregator is `grafana-agent` on a machine with ID 0.

1. Shell into the machine:

```shell
juju ssh 0
```

2. Check the status of the `grafana-agent` snap:

```shell 
sudo snap services grafana-agent
```

Ensure that the status of the snap is indicated as `active`.

For K8s charms, ensure the relevant pebble service is running by checking its status in the workload container. In this example, we'll assume we have the `opentelemetry-collector` k8s charm deployed with the name `otel` and we want to check the status of the pebble service in the workload container in unit 0. The name of the workload container is `otelcol`.

```{note}
You need to know the name of the workload container in order to shell into it. You can find this information by consulting the `containers` section of a charm's `charmcraft.yaml` file. Alternatively, you can use `kubectl describe pod` to view the containers inside the pod.    
```

1. Shell into the workload container:

```shell 
juju ssh --container otelcol otel/0
```

2. Check the status of the `otelcol` pebble service:

```shell 
pebble services otelcol
```

#### Confirm the backend is reachable
It is possible that the aggregator is running, but failing to remote write metrics into the metrics backend. This can occur if there are network or firewall issues, leaving the aggregator unable to successfully hit the metrics backend's remote write endpoint.

The causes in these cases can often be revealed by looking at the workload logs and looking for logs that suggest issues in reaching a host. The logs will often mention timeouts, DNS name resolution failures, TLS certificate issues, or more broadly "export failures".

1. For machine aggregators, view the snap logs:

```shell
sudo snap logs opentelemetry-collector
```

2. For K8s aggregators, use `juju ssh` and `pebble logs` to view the workload logs. For example, for `opentelemetry-collector-k8s` unit 0, you will need to look at the Pebble logs in the `otelcol` container:

```shell
juju ssh --container otelcol opentelemetry-collector/0 pebble logs
```

In some cases, the backend may be unreachable due to SSL/TLS related issues. This often happens when your aggregator is located outside the Juju model where your COS instance lives and you are using TLS communication when the aggregator tries to reach the backend (external or full TLS). If you are using ingress, it is required for the aggregator to trust the CA that signed the backend or ingress provider (e.g. Traefik).

#### Inspect existing `up` time series
Perhaps the metrics *do* reach Prometheus, but the `expr` labels we have rendered in the alert do not match the actual metric labels. You can confirm by going to the Prometheus (or Grafana) UI and querying for `up`. Compare the set of labels you get for the returned `up` time series.


## Compressed rules in relation databags

In some relations, rules are compressed in the databag and are not human readable, making troubleshooting difficult. Assuming your unit and endpoint are named `otelcol/0` and `receive-otlp` respectively, then you can view the compressed rules with:

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

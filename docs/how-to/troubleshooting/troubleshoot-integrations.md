# Troubleshooting integrations

Integrating a charm with [COS](https://charmhub.io/topics/canonical-observability-stack) means:

- having your app's metrics and corresponding alert rules reach [Prometheus](https://charmhub.io/prometheus-k8s/).
- having your app's logs and corresponding alert rules reach [Loki](https://charmhub.io/loki-k8s/).
- having your app's dashboards reach [grafana](https://charmhub.io/grafana-k8s/).

The COS team is responsible for some aspects of testing, and some aspects of testing belong to 
the charms integrating with COS.

## Tests for the built-in alert rules

### Unit tests

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

### Integration tests

```{note}
A fresh deployment shouldn't fire alerts. This can happen when the alert rules are not taking into account
that there is no prior data, thus interpreting it as `0`.
```

## Tests for the metrics endpoint and scrape job

### Integration tests

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

## Tests for log lines

### Integration tests

When related to Loki, make sure your logging sources are listed in:
  - `GET /loki/api/v1/label/filename/values`
  - `GET /loki/api/v1/label/juju_unit/values`

## Tests for dashboards

### Unit tests

* JSON linting

### Integration tests

Make sure the dashboards manifest you have in the charm matches:

```bash
$ juju ssh grafana/0 curl http://admin:password@localhost:3000/api/search
```

## Data Duplication

### Multiple grafana-agent apps related to the same principle

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

## Additional thoughts
- A rock's CI could dump a record of the `/metrics` endpoint each time the rock is built. This 
  way some integration tests could turn into unit tests.

## See also

- [Troubleshooting Prometheus Integrations](https://discourse.charmhub.io/t/prometheus-k8s-docs-troubleshooting-integrations/14351)
- [Troubleshooting missing logs](https://discourse.charmhub.io/t/loki-k8s-docs-troubleshooting-missing-logs/14187)
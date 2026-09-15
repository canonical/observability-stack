# Solution tests

For a given solution (e.g. `cos`, `cos-lite`), the solution tests deploy that
solution's Terraform module and run a set of assertions on the resulting deployment, to verify
all works as expected.

CI discovers solutions dynamically (any directory under `tests/solution/` containing a
`terraform/` subdirectory) and runs these tests on a schedule. See `solution.just` for how
these tests are invoked.

## Prerequisites

- `terraform` or `opentofu`, and `just` (`sudo snap install terraform --classic`,
  `sudo snap install astral-uv --classic`, etc. -- or use `concierge`, as CI does).
- A bootstrapped Juju controller with a Kubernetes cloud, e.g. a local `microk8s` controller.

Both the Juju Terraform provider and [jubilant](https://github.com/canonical/jubilant) deploy to
whichever Juju controller is currently active (`juju switch`) -- run `juju switch <controller>`
to your intended controller first if you have more than one registered, so you don't
accidentally deploy into the wrong one. `just solution test` prints the current
controller/model (`juju whoami`) as a sanity check before it does anything.

## Running a solution test

From the repo root:

```bash
just solution test cos-lite   # or: cos
```

This will:

1. `terraform init` and `terraform apply` the solution's Terraform wrapper module
   (`tests/solution/<name>/terraform/`), deploying it into a new model on the current controller.
2. Run that solution's `pytest-bdd` scenario (`tests/solution/<name>/test_solution.py`), which
   connects to the model Terraform just created and waits for it to become active/idle.

The Terraform module is *not* destroyed automatically afterwards (so you can inspect a failure).
Clean up when you're done:

```bash
terraform -chdir=tests/solution/cos-lite/terraform destroy -auto-approve
```

### Running against an already-deployed model

The `given` step (`the solution has been deployed`, defined in `steps/common_steps.py`) can skip
discovering a model from Terraform output entirely: set `SOLUTION_MODEL` (optionally
`<controller>:<model>`) and it's used as-is. This lets an external suite that deploys a solution
some other way reuse these same steps against its own model:

```bash
cd tests/solution
SOLUTION_MODEL="microk8s-localhost:cos-lite" uv run --frozen --isolated pytest -vv --capture=no cos-lite
```

## Adding a new scenario

Add a new `.feature` file per capability (e.g. `features/alerting.feature`). Reuse the existing
steps where they apply -- most scenarios want the `Given the solution has been deployed` /
`And the model is healthy` background. Every solution's `test_solution.py` loads all of
`features/`, so an untagged
scenario runs for every solution; tag a scenario with one or more solution names (e.g. `@cos`,
matching the solution's directory name) to restrict it to those solutions -- `conftest.py`
deselects it everywhere else. Steps stay shared regardless of tags.

A `Feature:` describes a capability in solution-agnostic terms ("the metrics backend scrapes every
component that exposes metrics"); the scenarios under it name the concrete workload. That way COS
can reuse the same feature file by adding its own scenario (e.g. one driving Mimir alongside the
COS Lite one driving Prometheus), each tagged for its solution.

### Writing steps

Steps are **declarative**: each one states a fact about the system and asserts it on its own, so
it can be dropped into any scenario.

```gherkin
Then Prometheus has metrics from the "loki" application
```

Prefer this over splitting a check into a `When` that fetches and a `Then` that inspects the
result: the pair is only meaningful in that exact order, which makes both halves unreusable. These
suites deploy nothing (the deployment is external) and mutate nothing, so most scenarios are
legitimately just a background plus one or more `Then`s, with no `When` at all.

Step definitions live in `steps/`, grouped by **the domain concept they talk about** rather than
by the feature file that uses them:

| Module | Owns |
| --- | --- |
| `steps/deployment.py` | the model: which one, and whether it is healthy |
| `steps/telemetry.py` | signals reaching their backend: metrics, logs, traces |
| `steps/grafana.py` | Grafana as a domain: dashboards, datasources |

Grouping by domain (rather than one module per `.feature`) is what keeps steps reusable: two
features already share `steps/grafana.py`, and `the model is healthy` serves as both the
background of every feature and the assertion of the smoke test. Register new modules in
`conftest.py`'s `pytest_plugins`.

### Talking to workloads

Assertions against running workloads go through
[observability-clients](https://pypi.org/project/observability-clients/). `clients.py` provides one
fixture per workload -- `prometheus`, `loki`, `grafana`, `alertmanager`, `mimir`, `tempo` -- each
returning a client already pointed at that application (URL resolved from the unit address, scheme
probed, Grafana authenticated as admin). A step just asks for the one it needs:

```python
@then(parsers.parse('Loki has logs from the "{application}" application'))
def loki_has_logs_from(loki: Loki, application: str): ...
```

Fixtures are lazy, so a fixture is only built when a scenario actually requests it. `clients.py`
can therefore hold fixtures for components no single solution deploys in full: COS Lite scenarios
request `prometheus`, COS scenarios request `mimir`, and neither pays for the other. For the same
reason, a backend gets one step definition per workload (`Prometheus has metrics from ...`,
`Mimir has metrics from ...`) delegating to a shared helper, rather than one step parameterized
over the backend name -- a parameterized step cannot know which fixture to request.

Because the background already waits for active/idle, steps assert directly; only add retries
where data genuinely trails that (e.g. the first Prometheus scrape, which uses `tenacity` in
`steps/telemetry.py`).

### Solutions that collect telemetry differently

COS Lite has each component deliver its own telemetry, while COS routes everything through
OpenTelemetry Collector. The assertions do not need to care: every scenario looks for a
`juju_application` label, which names the component the telemetry *originated from*, not the one
that delivered it. Keeping the collection path out of the assertion is what lets both solutions
share `features/logs.feature` and one `Loki has logs from ...` step, differing only in the
scenario name and the list of components in the `Examples:` table.

## Adding a new solution

1. Create `tests/solution/<name>/terraform/main.tf` wrapping `terraform/<name>`, and
   `outputs.tf` exposing `model_name`.
2. Add an empty `tests/solution/<name>/__init__.py`.
3. Add `tests/solution/<name>/test_solution.py` containing:
   ```python
   from pytest_bdd import scenarios

   scenarios("../features")
   ```
4. Run `just solution test <name>` to verify it.


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

The `given` step (`the solution has been deployed`, defined in `steps/deployment.py`) can skip
discovering a model from Terraform output entirely: set `SOLUTION_MODEL` (optionally
`<controller>:<model>`) and it's used as-is. This lets an external suite that deploys a solution
some other way reuse these same steps against its own model:

```bash
cd tests/solution
SOLUTION_MODEL="microk8s-localhost:cos-lite" uv run --frozen --isolated pytest -vv --capture=no cos-lite
```

### Running a specific mode

Some solutions support more than one **mode** (e.g. `cos-lite` supports `tls-internal` /
`tls-none`). Pass it as a second argument:

```bash
just solution test cos-lite tls-none
```

In CI, modes and Juju channels are matrix dimensions instead
(`.github/workflows/_solution-test-modes.yaml`).

## Adding a new scenario

Feature files live under each solution's own `<name>/features/`, plus `features/smoke.feature`
at the top level, shared by every solution since it names no concrete workload. Add a new
`.feature` file to the solution(s) it applies to; if two solutions want the same capability
(e.g. both scrape a metrics backend), give each its own scenario naming its own workload rather
than sharing a file -- there is no cross-solution tagging to keep in sync. Reuse the existing
steps where they apply -- most scenarios want the `Given the solution has been deployed` /
`And the model is healthy` background.

A scenario can also be restricted to a **mode** by tagging it (e.g. `@tls-none`) -- `conftest.py`
deselects it when that mode isn't active; an untagged scenario runs under every mode. New mode
values also need adding to `_MODES` in `conftest.py`.

### Writing steps

Steps are declarative: each one states a fact about the system and asserts it on its own, so it
can be dropped into any scenario. These suites deploy and mutate nothing, so most scenarios are
just a background plus one or more `Then`s.

Step definitions live in `steps/`, grouped by the domain concept they talk about (e.g.
`steps/deployment.py`, `steps/telemetry.py`, `steps/grafana.py`, `steps/tls.py`) rather than by
the feature file that uses them. Register new modules in `conftest.py`'s `pytest_plugins`.

### Talking to workloads

Assertions against running workloads go through
[observability-clients](https://pypi.org/project/observability-clients/) fixtures in `clients.py`,
built lazily for each workload. Only
add retries where data genuinely trails active/idle (e.g. the first Prometheus scrape).

## Adding a new solution

1. Create `tests/solution/<name>/terraform/main.tf` wrapping `terraform/<name>`, and
   `outputs.tf` exposing `model_name`.
2. Add an empty `tests/solution/<name>/__init__.py`.
3. Add `tests/solution/<name>/features/` with that solution's own scenarios.
4. Add `tests/solution/<name>/test_solution.py` containing:
   ```python
   from pytest_bdd import scenarios

   scenarios("../features", "features")
   ```
5. Run `just solution test <name>` to verify it.



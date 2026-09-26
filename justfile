set quiet  # Recipes are silent by default
set export  # Just variables are exported to the environment

terraform := `which terraform || which tofu || echo ""` # require 'terraform' or 'opentofu'
uv_flags := "--frozen --isolated"

mod solution

[private]
default:
  just --list

# Update uv.lock with the latest deps
lock:
  uv lock --upgrade --no-cache

# Lint everything
[group("Lint")]
lint: lint-workflows lint-terraform lint-terraform-docs check-tfvars

# Format everything
[group("Format")]
fmt: format-terraform format-terraform-docs

# Run unit tests
[group("Unit")]
unit: (unit-test "cos") (unit-test "cos-lite") (unit-test "cos-dev")

# Lint the Github workflows
[group("Lint")]
lint-workflows:
  uvx --from=actionlint-py actionlint

# Lint the Terraform modules
[group("Lint")]
[working-directory("./terraform")]
lint-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade && $terraform fmt -check -recursive -diff) || exit 1; done

# Lint the Terraform documentation
[group("Lint")]
lint-terraform-docs:
  terraform-docs --config .tfdocs-config.yml --output-check .

# Check that committed example .tfvars bind to their module's variables.
# Terraform only *warns* on an undeclared variable, so a rotted example would
# otherwise pass unnoticed; this turns that warning (and any console error)
# into a hard failure. See terraform/*/examples/.
[group("Lint")]
[working-directory("./terraform")]
check-tfvars:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do \
    [ -d "${repo}examples" ] || continue; \
    ( cd "$repo" \
      && echo "Checking ${repo}examples..." \
      && $terraform init -upgrade >/dev/null \
      && for f in examples/*.tfvars; do \
           out=$($terraform console -var-file="$f" </dev/null 2>&1) || { echo "$out"; echo "FAIL: $repo$f errors"; exit 1; }; \
           if echo "$out" | grep -q "Value for undeclared variable"; then echo "FAIL: $repo$f references an undeclared variable"; exit 1; fi; \
           echo "OK: $repo$f"; \
         done ) || exit 1; \
  done

# Format the Terraform modules
[group("Format")]
[working-directory("./terraform")]
format-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade && $terraform fmt -recursive -diff) || exit 1; done

# Format the Terraform documentation
[group("Format")]
format-terraform-docs:
  terraform-docs --config .tfdocs-config.yml .

# Validate the Terraform modules
[group("Static")]
[working-directory("./terraform")]
validate-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade && $terraform validate) || exit 1; done

# Run a unit test
[group("Unit")]
[working-directory("./terraform")]
unit-test module:
  echo "==> Running unit tests for module: {{module}}"
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  $terraform -chdir={{module}} init -upgrade && $terraform -chdir={{module}} test

# Run integration tests
[group("Integration")]
[working-directory("./tests/integration")]
integration *args='':
  uv run ${uv_flags} pytest -vv -ra --capture=no --exitfirst {{args}}

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
lint: lint-workflows lint-terraform lint-terraform-docs check-presets

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

# Check that committed preset value files bind to their module's variables.
#
# Presets live under terraform/*/presets/ and are consumed by tools (e.g.
# Atelier) and by `terraform -var-file`; the module does not read them. Terraform
# only *warns* on an undeclared top-level variable in a var-file, so a renamed or
# removed variable would silently rot a preset. This turns that warning into a
# hard failure. Nested typos are not caught: Terraform drops unknown attributes
# during type conversion without complaint.
[group("Lint")]
[working-directory("./terraform")]
check-presets:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do \
    [ -d "${repo}presets" ] || continue; \
    ( cd "$repo" \
      && echo "Checking ${repo}presets..." \
      && $terraform init -upgrade >/dev/null \
      && for f in presets/*.tfvars.json; do \
           jq -e . "$f" >/dev/null || { echo "FAIL: $repo$f is not valid JSON"; exit 1; }; \
           out=$($terraform console -no-color -var-file="$f" </dev/null 2>&1 || true); \
           if echo "$out" | grep -q "Value for undeclared variable"; then \
             echo "$out"; echo "FAIL: $repo$f references an undeclared variable"; exit 1; \
           fi; \
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

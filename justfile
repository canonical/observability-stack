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
lint: lint-workflows lint-terraform lint-terraform-docs lint-doc-refs lint-presets

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

# In-version references must stay branch-relative.
# Lint the docs for hardcoded versioned links e.g., /latest/, /track-3.0/, etc.
# release-policy.md and upgrade.md are exempt: release-policy.md tabulates every
# published version, and upgrade.md links to the previous release's guide on purpose.
[group("Lint")]
lint-doc-refs:
  #!/usr/bin/env bash
  set -euo pipefail
  pattern='documentation\.ubuntu\.com/observability/(latest|stable|track[-/][^/)]*)/'
  if grep -rn --include='*.md' --exclude='release-policy.md' --exclude='upgrade.md' -E "$pattern" docs; then
    echo "FAIL: detected an internal link that references a branch; correct internal links to be relative (../link) instead of a versioned observability docs URL" >&2
    exit 1
  fi

# Lint the .tfvars presets under terraform/*/presets/ against each module's variables.tf
[group("Lint")]
[working-directory("./terraform")]
lint-presets:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -eu; fail=0; for f in */presets/*.tfvars; do \
    [ -f "$f" ] || continue; \
    module=$(dirname "$(dirname "$f")"); tmp=$(mktemp -d); \
    cp "$module/variables.tf" "$tmp/"; : > "$tmp/empty.tfvars"; \
    vars=$(grep -oE '^variable "[a-z_]+"' "$module/variables.tf" | sed -E 's/variable "([a-z_]+)"/\1/'); \
    (cd "$tmp" && $terraform init -no-color >/dev/null 2>&1); \
    expr="{ "; for v in $vars; do expr="$expr$v = try(keys(var.$v), null), "; done; expr="$expr}"; \
    declared=$(cd "$tmp" && echo "$expr" | $terraform console -var-file=empty.tfvars 2>/dev/null); \
    rm -rf "$tmp"; bad=""; \
    for v in $vars; do \
      dk=$(printf '%s\n' "$declared" | awk -v k="\"$v\"" '$1==k{i=1;next} i&&/\]/{exit} i{gsub(/[ ",]/,"");if($0!="")print}'); \
      for s in $(sed -E 's/\{/\{\n/g; s/,/\n/g; s/\}/\n}/g' "$f" | awk -v n="$v" '$0~"^[[:space:]]*"n"[[:space:]]*=.*[{]"{b=1;next} b&&/^\}/{b=0;next} b&&/^[[:space:]]*[a-z_]+[[:space:]]*=/{print $1}'); do \
        printf '%s\n' "$dk" | grep -qx "$s" || bad="$bad  $v.$s: not declared in $module\n"; \
      done; \
    done; \
    for t in $(grep -oE '^[a-z_]+[[:space:]]*=' "$f" | tr -d ' =' | sort -u); do printf '%s\n' "$vars" | grep -qx "$t" || bad="$bad  $t: not declared in $module\n"; done; \
    [ -n "$bad" ] && { printf "FAIL: %s\n%b" "$f" "$bad"; fail=1; } || echo "OK: $f"; \
  done; [ "$fail" -eq 0 ] || exit 1

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

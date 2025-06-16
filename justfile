set quiet  # Recipes are silent by default
set export  # Just variables are exported to the environment

terraform := `which terraform || which tofu || echo ""` # require 'terraform' or 'opentofu'

[private]
default:
  just --list

# Lint everything
[group("Lint")]
lint: lint-workflows lint-terraform

# Format everything 
[group("Format")]
fmt: format-terraform

# Lint the Github workflows
[group("Lint")]
lint-workflows:
  uvx --from=actionlint-py actionlint

# Lint the Terraform modules
[group("Lint")]
[working-directory("./terraform/modules")]
lint-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade -reconfigure && $terraform fmt -check -recursive -diff) || exit 1; done

# Format the Terraform modules
[group("Format")]
[working-directory("./terraform/modules")]
format-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade -reconfigure && $terraform fmt -recursive -diff) || exit 1; done

# Validate the Terraform modules
[group("Validate")]
[working-directory("./terraform/modules")]
validate-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade -reconfigure && $terraform validate) || exit 1; done

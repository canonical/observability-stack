set quiet  # Recipes are silent by default
set export  # Just variables are exported to the environment

terraform := `which terraform || which tofu || echo ""` # require 'terraform' or 'opentofu'

[private]
default:
  just --list

# Lint everything
[group("Lint")]
lint: lint-workflows lint-terraform lint-terraform-docs

# Format everything
[group("Format")]
fmt: format-terraform format-terraform-docs

# Lint the Github workflows
[group("Lint")]
lint-workflows:
  uvx --from=actionlint-py actionlint

# Lint the Terraform modules
[group("Lint")]
[working-directory("./terraform")]
lint-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade -reconfigure && $terraform fmt -check -recursive -diff) || exit 1; done

# Lint the Terraform documentation
[group("Lint")]
lint-terraform-docs:
  terraform-docs --config .tfdocs-config.yml terraform/aws-infra/ --output-file {{justfile_directory()}}/docs/reference/terraform/aws-infra.md
  terraform-docs --config .tfdocs-config.yml terraform/cos/ --output-file {{justfile_directory()}}/docs/reference/terraform/cos.md
  terraform-docs --config .tfdocs-config.yml terraform/cos-lite/ --output-file {{justfile_directory()}}/docs/reference/terraform/cos-lite.md
  terraform-docs --config .tfdocs-config.yml terraform/loki/ --output-file {{justfile_directory()}}/docs/reference/terraform/loki.md
  terraform-docs --config .tfdocs-config.yml terraform/mimir/ --output-file {{justfile_directory()}}/docs/reference/terraform/mimir.md
  terraform-docs --config .tfdocs-config.yml terraform/minio/ --output-file {{justfile_directory()}}/docs/reference/terraform/minio.md
  terraform-docs --config .tfdocs-config.yml terraform/tempo/ --output-file {{justfile_directory()}}/docs/reference/terraform/tempo.md

# Format the Terraform modules
[group("Format")]
[working-directory("./terraform")]
format-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade -reconfigure && $terraform fmt -recursive -diff) || exit 1; done

# Format the Terraform documentation
[group("Format")]
format-terraform-docs:
  terraform-docs --config .tfdocs-config.yml terraform/aws-infra/ --output-file {{justfile_directory()}}/docs/reference/terraform/aws-infra.md
  terraform-docs --config .tfdocs-config.yml terraform/cos/ --output-file {{justfile_directory()}}/docs/reference/terraform/cos.md
  terraform-docs --config .tfdocs-config.yml terraform/cos-lite/ --output-file {{justfile_directory()}}/docs/reference/terraform/cos-lite.md
  terraform-docs --config .tfdocs-config.yml terraform/loki/ --output-file {{justfile_directory()}}/docs/reference/terraform/loki.md
  terraform-docs --config .tfdocs-config.yml terraform/mimir/ --output-file {{justfile_directory()}}/docs/reference/terraform/mimir.md
  terraform-docs --config .tfdocs-config.yml terraform/minio/ --output-file {{justfile_directory()}}/docs/reference/terraform/minio.md
  terraform-docs --config .tfdocs-config.yml terraform/tempo/ --output-file {{justfile_directory()}}/docs/reference/terraform/tempo.md

# Validate the Terraform modules
[working-directory("./terraform")]
validate-terraform:
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  set -e; for repo in */; do (cd "$repo" && echo "Processing ${repo%/}..." && $terraform init -upgrade -reconfigure && $terraform validate) || exit 1; done

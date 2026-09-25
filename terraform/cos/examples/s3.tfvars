# S3 (SeaweedFS) backend configuration for the COS module.
#
# These are development defaults: the endpoint points at a local SeaweedFS and
# the credentials are placeholders. Replace them before using against real
# infrastructure.
#
# Apply with Atelier:
#   atelier module add https://github.com/canonical/observability-stack.git \
#     --module terraform/cos --tfvars --var-file s3.tfvars
#
# Or with Terraform directly, from the module directory:
#   terraform plan -var-file=examples/s3.tfvars

s3_endpoint   = "http://10.1.0.95:8333"
s3_access_key = "placeholder"
s3_secret_key = "placeholder"

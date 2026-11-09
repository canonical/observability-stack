set quiet  # Recipes are silent by default
set export  # Just variables are exported to the environment

terraform := `which terraform || which tofu || echo ""` # require 'terraform' or 'opentofu'
uv_flags := "--frozen --isolated"

[private]
@default:
  just --list solution

# Apply a solution's Terraform wrapper in the given mode, then run its tests against it
[arg("internal_tls", long="internal-tls", pattern="true|false", help="Encrypt the traffic between the components")]
[arg("external_ca", long="external-ca", pattern="true|false", help="Terminate TLS in the ingress with an external CA; needs --ingress=true")]
[arg("ingress", long="ingress", pattern="true|false", help="Deploy the ingress")]
[group("test")]
[working-directory("./tests/solution")]
test solution="cos-lite" internal_tls="true" external_ca="false" ingress="true" *pytest_args:
  #!/usr/bin/env bash
  # Deploys into whichever Juju controller is currently active -- `juju switch`
  # to the intended one first. Arguments after `--` go to pytest.
  set -euo pipefail
  echo "==> Testing solution: {{solution}}"
  juju whoami
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  if [ "{{external_ca}}" = "true" ] && [ "{{ingress}}" = "false" ]; then
    echo "ERROR: --external-ca=true needs --ingress=true: the external CA only signs the ingress's certificate."
    exit 1
  fi

  # Juju deploys amd64 charms unless told otherwise; the cluster runs on this machine.
  vars=(-var "internal_tls={{internal_tls}}" -var "external_ca={{external_ca}}" -var "arch=$(dpkg --print-architecture)")
  if [ "{{ingress}}" = "false" ]; then
    vars+=(-var-file "$(cd ../.. && pwd)/terraform/{{solution}}/presets/no-ingress.tfvars")
  fi

  tf=("${terraform}" -chdir="{{solution}}/terraform")
  "${tf[@]}" init -upgrade
  # Apply is idempotent, so retry once to get past transient errors.
  "${tf[@]}" apply -auto-approve "${vars[@]}" || "${tf[@]}" apply -auto-approve "${vars[@]}"
  uv run ${uv_flags} pytest -vv -ra --capture=no "{{solution}}" {{pytest_args}}

# Promote every charm in a solution from /beta to /candidate
[group("promote")]
promote solution="cos-lite" ref="main":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "==> Promoting solution: {{solution}} (ref: {{ref}})"
  charms_tracks=$(just charm-tracks "{{solution}}" "{{ref}}")
  if [ -z "$charms_tracks" ]; then
    echo "ERROR: no pinned charms found for solution '{{solution}}'; refusing to promote nothing."
    exit 1
  fi
  while read -r charm track; do
    echo "--> Promoting $charm from ${track}/beta to ${track}/candidate"
    charmcraft promote --name "$charm" --from-channel "${track}/beta" --to-channel "${track}/candidate" --yes
  done <<< "$charms_tracks"

# List the charm name + track pinned by each charm in a product module
[group("promote")]
charm-tracks module ref='main':
  #!/usr/bin/env bash
  set -euo pipefail
  excluded_charms="self-signed-certificates traefik-k8s s3-integrator"
  upgrades=$(git show "{{ref}}:terraform/{{module}}/upgrades.tf")
  locals=$(git show "{{ref}}:terraform/{{module}}/locals.tf")

  charm_keys=""
  in_block=0
  charm=""
  key=""
  while IFS= read -r line; do
    if [[ "$line" =~ data[[:space:]]*\"juju_charm\"[[:space:]]*\" ]]; then
      in_block=1
      continue
    fi
    if [ "$in_block" -eq 1 ] && [[ "$line" =~ ^\} ]]; then
      in_block=0
      charm=""
      key=""
      continue
    fi
    if [ "$in_block" -eq 1 ] && [[ "$line" =~ charm[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]]; then
      charm="${BASH_REMATCH[1]}"
    fi
    if [ "$in_block" -eq 1 ] && [[ "$line" =~ channel[[:space:]]*=[[:space:]]*local\.channels\.([a-zA-Z0-9_]+) ]]; then
      key="${BASH_REMATCH[1]}"
    fi
    if [ "$in_block" -eq 1 ] && [ -n "$charm" ] && [ -n "$key" ]; then
      charm_keys+="$charm $key"$'\n'
      charm=""
      key=""
    fi
  done <<< "$upgrades"

  declare -A tracks
  in_tracks=0
  while IFS= read -r line; do
    if [[ "$line" =~ tracks[[:space:]]*=[[:space:]]*\{ ]]; then
      in_tracks=1
      continue
    fi
    if [ "$in_tracks" -eq 1 ] && [[ "$line" =~ ^\ \ \} ]]; then
      in_tracks=0
      continue
    fi
    if [ "$in_tracks" -eq 1 ] && [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]]; then
      tracks["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
    fi
  done <<< "$locals"

  while read -r charm key; do
    [ -z "$charm" ] && continue
    case " $excluded_charms " in *" $charm "*) continue ;; esac
    track="${tracks[$key]:-}"
    [ -n "$track" ] && printf '%s %s\n' "$charm" "$track"
  done <<< "$charm_keys"

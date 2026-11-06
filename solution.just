set quiet  # Recipes are silent by default
set export  # Just variables are exported to the environment

terraform := `which terraform || which tofu || echo ""` # require 'terraform' or 'opentofu'
uv_flags := "--frozen --isolated"

[private]
@default:
  just --list solution

# Deploys into whichever Juju controller is currently active -- `juju switch`
# to the intended one first. Extra arguments go to pytest, and the mode options
# also to Terraform, e.g.:
# `just solution test cos-lite --internal-tls=true --external-ca=false --ingress=true`
# Apply a solution's Terraform wrapper, then run its test suite
[group("test")]
[working-directory("./tests/solution")]
test solution="cos-lite" *args='':
  #!/usr/bin/env bash
  set -euo pipefail
  echo "==> Testing solution: {{solution}}"
  juju whoami
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi

  # The mode options also go to the Terraform wrapper; empty keeps its default.
  internal_tls="" external_ca="" ingress=""
  for arg in {{args}}; do
    case "$arg" in
      --internal-tls=*) internal_tls="${arg#*=}" ;;
      --external-ca=*) external_ca="${arg#*=}" ;;
      --ingress=*) ingress="${arg#*=}" ;;
      --internal-tls|--external-ca|--ingress) echo "ERROR: use $arg=<value>"; exit 1 ;;
    esac
  done
  if [ "$external_ca" = "true" ] && [ "$ingress" = "false" ]; then
    echo "ERROR: --external-ca=true with --ingress=false isn't an allowed combination."
    exit 1
  fi
  vars=()
  if [ -n "$internal_tls" ]; then vars+=(-var "internal_tls=$internal_tls"); fi
  if [ -n "$external_ca" ]; then vars+=(-var "external_ca=$external_ca"); fi
  if [ "$ingress" = "false" ]; then
    vars+=(-var-file "$(cd ../.. && pwd)/terraform/{{solution}}/presets/no-ingress.tfvars")
  fi

  tf=("${terraform}" -chdir="{{solution}}/terraform")
  "${tf[@]}" init -upgrade
  # Apply is idempotent, so retry once to get past transient errors.
  "${tf[@]}" apply -auto-approve "${vars[@]}" || "${tf[@]}" apply -auto-approve "${vars[@]}"
  uv run ${uv_flags} pytest -vv -ra --capture=no "{{solution}}" {{args}}

# Set KUBECTL to override the kubectl command (default: kubectl, then k8s, then microk8s).
# Print Juju and Kubernetes state for every model, to debug a failed run
[group("test")]
debug-dump:
  #!/usr/bin/env bash
  set -uo pipefail  # no -e: print as much as possible, even if one command fails
  if [ -n "${KUBECTL:-}" ]; then read -ra kubectl <<< "$KUBECTL"
  elif command -v kubectl >/dev/null; then kubectl=(kubectl)
  elif command -v k8s >/dev/null; then kubectl=(sudo k8s kubectl)
  else kubectl=(microk8s kubectl); fi
  for model in $(juju models --format json | jq -r '.models[]."short-name" | select(. != "controller")'); do
    echo "=== juju status: $model ==="
    juju status -m "$model" --relations
    errored=$(juju status -m "$model" --format json | jq -r '.applications[].units // {} | to_entries[]
      | select(.value."workload-status".current == "error" or .value."juju-status".current == "error") | .key')
    for unit in $errored; do
      echo "=== juju debug-log: $unit ==="
      juju debug-log -m "$model" --limit 200 --include "$unit"
    done
    echo "=== juju debug-log: $model ==="
    juju debug-log -m "$model" --limit 200
    echo "=== kubectl: $model ==="
    "${kubectl[@]}" get pods,pvc -n "$model" -o wide
    "${kubectl[@]}" get events -n "$model" --sort-by=.lastTimestamp
  done
  echo "=== kubectl: cluster ==="
  "${kubectl[@]}" get pv,storageclass

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

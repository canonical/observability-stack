set quiet  # Recipes are silent by default
set export  # Just variables are exported to the environment

terraform := `which terraform || which tofu || echo ""` # require 'terraform' or 'opentofu'
uv_flags := "--frozen --isolated"

[private]
@default:
  just --list quality-gates

# Init/apply a solution's Terraform module, then run its solution test suite
[group("test")]
[working-directory("./tests/solution")]
test-solution solution="cos-lite":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "==> Testing solution: {{solution}}"
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  $terraform -chdir="{{solution}}/terraform" init -upgrade
  $terraform -chdir="{{solution}}/terraform" apply -auto-approve
  uv run ${uv_flags} pytest -vv -ra --capture=no "{{solution}}"

# Promote every charm in a solution from /beta to /candidate
[group("promote")]
promote-solution solution="cos-lite" ref="main":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "==> Promoting solution: {{solution}} (ref: {{ref}})"
  charms_tracks=$(just charm-tracks "{{solution}}" "{{ref}}")
  if [ -z "$charms_tracks" ]; then
    echo "No pinned charms found for solution '{{solution}}'; nothing to promote."
    exit 0
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

  charm_keys=$(awk '
    /data[[:space:]]*"juju_charm"[[:space:]]*"/ { in_block=1; next }
    in_block && /^\}/ { in_block=0; charm=""; key=""; next }
    in_block && match($0, /charm[[:space:]]*=[[:space:]]*"([^"]*)"/, m) { charm=m[1] }
    in_block && match($0, /channel[[:space:]]*=[[:space:]]*local\.channels\.([a-zA-Z0-9_]+)/, m) { key=m[1] }
    in_block && charm != "" && key != "" { print charm, key; charm=""; key="" }
  ' <<< "$upgrades")

  declare -A tracks
  while read -r tkey tval; do
    [ -n "$tkey" ] && tracks["$tkey"]="$tval"
  done < <(awk '
    /tracks[[:space:]]*=[[:space:]]*\{/ { in_tracks=1; next }
    in_tracks && /^  \}/ { in_tracks=0; next }
    in_tracks && match($0, /^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*=[[:space:]]*"([^"]*)"/, m) { print m[1], m[2] }
  ' <<< "$locals")

  while read -r charm key; do
    [ -z "$charm" ] && continue
    case " $excluded_charms " in *" $charm "*) continue ;; esac
    track="${tracks[$key]:-}"
    [ -n "$track" ] && printf '%s %s\n' "$charm" "$track"
  done <<< "$charm_keys"

set quiet  # Recipes are silent by default
set export  # Just variables are exported to the environment

terraform := `which terraform || which tofu || echo ""` # require 'terraform' or 'opentofu'
uv_flags := "--frozen --isolated"

[private]
@default:
  just --list solution

# Deploys into whichever Juju controller is currently active -- `juju switch`
# to the intended one first.
# Init/apply a solution's Terraform module, then run its solution test suite.
[group("test")]
[working-directory("./tests/solution")]
test solution="cos-lite" internal_tls="" external_ca="" ingress="" risk="":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "==> Testing solution: {{solution}}"
  juju whoami
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  uv run ${uv_flags} pytest -vv -ra --capture=no --internal-tls="{{internal_tls}}" --external-ca="{{external_ca}}" --ingress="{{ingress}}" --risk="{{risk}}" "{{solution}}"

# List the charm and resource revisions in each charm's <track>/<risk> channel for a product module.
[group("promote")]
pin module="cos-lite" ref="main" risk="candidate":
  #!/usr/bin/env bash
  set -euo pipefail
  charms_tracks=$(just solution charm-tracks "{{module}}" "{{ref}}")
  if [ -z "$charms_tracks" ]; then
    echo "ERROR: no pinned charms found for module '{{module}}' at '{{ref}}'" >&2
    exit 1
  fi
  fields="channel-map.channel.name,channel-map.channel.base.name,channel-map.channel.base.channel"
  fields+=",channel-map.channel.base.architecture,channel-map.revision.revision"
  fields+=",default-release.resources.name,default-release.resources.revision"
  while read -r charm track; do
    channel="${track}/{{risk}}"
    # The public API exposes resources for the default (amd64) release only.
    info=$(curl -fsS --get "https://api.charmhub.io/v2/charms/info/${charm}" \
      --data-urlencode "channel=${channel}" --data-urlencode "fields=${fields}")
    jq -c --arg charm "$charm" --arg track "$track" --arg channel "$channel" '{
      charm: $charm,
      track: $track,
      channel: $channel,
      revisions: [.["channel-map"][] | select(.channel.name == $channel) | {
        revision: .revision.revision,
        base: "\(.channel.base.name)@\(.channel.base.channel)",
        architecture: .channel.base.architecture
      }] | unique,
      resources: [.["default-release"].resources[]? | {name, revision}] | sort_by(.name)
    }' <<< "$info"
  done <<< "$charms_tracks" | jq -s '
    [.[] | select(.revisions == []) | .channel + " (" + .charm + ")"] as $empty
    | if $empty != [] then error("nothing released in: " + ($empty | join(", "))) else . end
  '

# A charm shared by several modules (same track) appears once. Fails if any of those channels is empty.
# Snapshot the <track>/<risk> revisions of every charm in the given product modules, as one JSON list.
[group("promote")]
snapshot ref risk +modules:
  #!/usr/bin/env bash
  set -euo pipefail
  for module in {{modules}}; do
    just solution pin "$module" "{{ref}}" "{{risk}}"
  done | jq -s '(add // []) | unique'

# Only if beta still matches the snapshot taken before testing
# (`just solution snapshot <ref> beta <modules> > snapshot`); charms whose
# candidate already matches beta are skipped. Writes a table to
# $GITHUB_STEP_SUMMARY when it is set.
# Promote the product modules' charms from <track>/beta to <track>/candidate. dry_run is "true" or "false".
[group("promote")]
promote-to-candidate ref snapshot dry_run +modules:
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{dry_run}}" in
    true|false) ;;
    *) echo "ERROR: dry_run must be 'true' or 'false', got '{{dry_run}}'" >&2; exit 1 ;;
  esac
  summary="${GITHUB_STEP_SUMMARY:-/dev/null}"
  if ! jq -e 'type == "array" and length > 0' "{{snapshot}}" > /dev/null; then
    echo "ERROR: '{{snapshot}}' is missing, not valid JSON, or empty; nothing promoted." >&2
    exit 1
  fi
  beta=$(just solution snapshot "{{ref}}" beta {{modules}})
  if ! changes=$(diff -u <(jq -S . "{{snapshot}}") <(jq -S . <<< "$beta")); then
    echo "ERROR: beta changed since the snapshot, so it may not be what was tested; nothing promoted. Start the gate again." >&2
    echo "$changes" >&2
    exit 1
  fi
  # Nothing in candidate yet for a charm, or an error reading candidate, makes
  # snapshot fail; then every charm is promoted (all of them match the tested snapshot).
  if ! candidate=$(just solution snapshot "{{ref}}" candidate {{modules}} 2> /dev/null); then
    candidate='[]'
  fi
  plan=$(jq -rn --argjson b "$beta" --argjson c "$candidate" '
    $b[] | . as $x
    | ($c | map(select(.charm == $x.charm and .track == $x.track)) | .[0]) as $y
    | [.charm, .track,
       (if $y != null and ($x | del(.channel)) == ($y | del(.channel)) then "skip" else "promote" end),
       (.revisions | map(.revision | tostring) | unique | join(", "))]
    | @tsv')
  if [ -z "$plan" ]; then
    echo "ERROR: nothing to promote" >&2
    exit 1
  fi
  if [ "{{dry_run}}" = "false" ]; then
    echo "==> Promoting to candidate"
    heading="Promoted to candidate"
  else
    echo "==> Dry run: printing the promote commands only (pass dry_run=false to promote)"
    heading="Dry run: would promote to candidate"
  fi
  {
    echo "### ${heading} ({{ref}})"
    echo
    echo "| Charm | Track | Beta revisions | Action |"
    echo "|---|---|---|---|"
  } >> "$summary"
  # Keep going after a failed promote, so the summary shows every charm's state.
  failed=0
  while IFS=$'\t' read -r charm track action revisions; do
    if [ "$action" = "skip" ]; then
      echo "--> ${charm}: ${track}/candidate already matches ${track}/beta, skipping"
    else
      args=(promote --name "$charm" --from-channel "${track}/beta" --to-channel "${track}/candidate" --yes)
      echo "--> charmcraft ${args[*]}"
      if [ "{{dry_run}}" = "false" ] && ! charmcraft "${args[@]}"; then
        echo "ERROR: promoting ${charm} failed" >&2
        action="FAILED"
        failed=1
      fi
    fi
    echo "| ${charm} | ${track} | ${revisions} | ${action} |" >> "$summary"
  done <<< "$plan"
  if [ "$failed" -ne 0 ]; then
    echo "ERROR: some promotions failed; see above. The others went through." >&2
    exit 1
  fi

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

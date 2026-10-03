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
test solution="cos-lite":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "==> Testing solution: {{solution}}"
  juju whoami
  if [ -z "${terraform}" ]; then echo "ERROR: please install terraform or opentofu"; exit 1; fi
  $terraform -chdir="{{solution}}/terraform" init -upgrade
  $terraform -chdir="{{solution}}/terraform" apply -auto-approve
  uv run ${uv_flags} pytest -vv -ra --capture=no "{{solution}}"

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

# Nothing in stable yet for a charm also counts as a change.
# Print "true" if a product module's charms differ between <track>/candidate and <track>/stable, else "false".
[group("promote")]
candidate-changed module ref:
  #!/usr/bin/env bash
  set -euo pipefail
  candidate=$(just solution pin "{{module}}" "{{ref}}" candidate)
  if ! stable=$(just solution pin "{{module}}" "{{ref}}" stable 2> /dev/null); then
    echo true
    exit 0
  fi
  jq -n --argjson c "$candidate" --argjson s "$stable" \
    '($c | map(del(.channel))) != ($s | map(del(.channel)))'

# Only if candidate still matches the snapshot taken before testing
# (`just solution pin <module> <ref> candidate > snapshot`); charms that already
# match stable are skipped.
# Promote a product module's charms from <track>/candidate to <track>/stable. Dry run by default.
[group("promote")]
promote-to-stable module ref snapshot dry_run="true":
  #!/usr/bin/env bash
  set -euo pipefail
  candidate=$(just solution pin "{{module}}" "{{ref}}" candidate)
  if ! changes=$(diff -u <(jq -S . "{{snapshot}}") <(jq -S . <<< "$candidate")); then
    echo "ERROR: candidate changed since the snapshot, so it may not be what was tested; nothing promoted. Start the gate again." >&2
    echo "$changes" >&2
    exit 1
  fi
  # Nothing in stable yet for a charm, or an error reading stable, makes pin fail;
  # then every charm is promoted (all of them match the tested snapshot).
  if ! stable=$(just solution pin "{{module}}" "{{ref}}" stable 2> /dev/null); then
    stable='[]'
  fi
  todo=$(jq -rn --argjson c "$candidate" --argjson s "$stable" '
    $c[] | . as $x
    | ($s | map(select(.charm == $x.charm)) | .[0]) as $y
    | select($y == null or ($x | del(.channel)) != ($y | del(.channel)))
    | "\(.charm) \(.track)"')
  if [ -z "$todo" ]; then
    echo "==> Nothing to promote: stable already matches candidate"
    exit 0
  fi
  if [ "{{dry_run}}" = "false" ]; then
    echo "==> Promoting to stable"
  else
    echo "==> Dry run: printing the promote commands only (pass dry_run=false to promote)"
  fi
  while read -r charm track; do
    args=(promote --name "$charm" --from-channel "${track}/candidate" --to-channel "${track}/stable" --yes)
    echo "--> charmcraft ${args[*]}"
    if [ "{{dry_run}}" = "false" ]; then charmcraft "${args[@]}"; fi
  done <<< "$todo"

# version_overrides and test_parameters must be JSON strings: workflow_dispatch
# inputs can't be objects. SolQA's COS recipes use only the ref and risk from
# version_overrides.
# Print the inputs for SolQA's Deploy Product workflow (deploy.yaml in canonical/terragrunt-deployment-pipelines).
[group("solqa")]
solqa-inputs product branch cluster test_ref test_repo="canonical/observability-stack":
  #!/usr/bin/env bash
  set -euo pipefail
  jq -nc --arg product "{{product}}" --arg branch "{{branch}}" --arg cluster "{{cluster}}" \
    --arg ref "{{test_ref}}" --arg repo "{{test_repo}}" '{
      type: "solution",
      substrate: "maas_physical",
      product: $product,
      cluster: $cluster,
      version_overrides: ({cos: {ref: $branch, risk: "candidate"}} | tojson),
      test_parameters: ({repo: $repo, ref: $ref, args: [$product]} | tojson)
    }'

# expected_title and not_before check that the run is the one we started:
# SolQA's executor takes the newest run, which may be another team's.
# Exit 0 only if our tests ran and passed in a SolQA Deploy Product run.
[group("solqa")]
solqa-passed run_id expected_title="" not_before="":
  #!/usr/bin/env bash
  set -euo pipefail
  repo="canonical/terragrunt-deployment-pipelines"
  url="https://github.com/${repo}/actions/runs/{{run_id}}"
  run=$(gh api "repos/${repo}/actions/runs/{{run_id}}")
  title=$(jq -r .display_title <<< "$run")
  created=$(jq -r .created_at <<< "$run")
  status=$(jq -r .status <<< "$run")
  if [ -n "{{expected_title}}" ] && [ "$title" != "{{expected_title}}" ]; then
    echo "ERROR: $url is '$title', not '{{expected_title}}': not the run we started" >&2
    exit 1
  fi
  if [ -n "{{not_before}}" ] && [[ "$created" < "{{not_before}}" ]]; then
    echo "ERROR: $url was created at $created, before {{not_before}}: not the run we started" >&2
    exit 1
  fi
  if [ "$status" != "completed" ]; then
    echo "ERROR: $url has not finished (status: $status)" >&2
    exit 1
  fi
  # The step that runs our sqa_tests; it fails if any test fails.
  step=$(gh api "repos/${repo}/actions/runs/{{run_id}}/jobs" --paginate \
    --jq '.jobs[].steps[] | select(.name == "Run SQA tests") | .conclusion')
  case "$step" in
    success) echo "PASSED: our tests passed in $url" ;;
    failure) echo "FAILED: our tests failed in $url" >&2; exit 1 ;;
    *) echo "FAILED: our tests did not run in $url (step result: '${step:-missing}'); the lab or pipeline failed first. Start the gate again." >&2; exit 1 ;;
  esac

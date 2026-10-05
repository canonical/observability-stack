# Product manifest that drives release metadata.
# Pinned to a commit for now; repin to a tag/sha (or main) once
# canonical/observability#503 merges.
manifest_url := "https://raw.githubusercontent.com/canonical/observability/03951447a73e0683b989c3069f6bc0bb5579b4d0/manifest.yaml"

# The products cut from this repo. Each has a module under terraform/ whose
# `tracks` block the manifest freezes.
products := "cos cos-lite"

# Emit a product's frozen charm tracks, one `key = "track"` per line.
# Read with $(...) rather than a redirect: a nested `just` writing to a
# redirected stdout fails, but a captured one is fine.
[private]
_tracks product release:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ -n ${MANIFEST:-} ]]; then manifest=$(cat "$MANIFEST"); else manifest=$(curl -fsSL {{manifest_url}}); fi
  printf '%s' "$manifest" | PRODUCT={{product}} RELEASE={{release}} yq -r '.products[] | select(.name == env(PRODUCT)) | .releases[] | select(.name == env(RELEASE)) | .components // {} | to_entries | sort_by(.key)[] | .key + " = \"" + .value + "\""'

# Check the manifest's charm tracks against the modules.
[group("Release")]
check-tracks release:
  #!/usr/bin/env bash
  set -euo pipefail

  # A cut freezes each module's `tracks` block from the manifest, so a track the
  # module reads but the manifest omits breaks the module, and a track the
  # manifest defines but the module never reads is dropped on the floor. Catch
  # both here, before any branch exists.
  fail=0
  for product in {{products}}; do
    locals=terraform/$product/locals.tf
    used=$(grep -oE 'tracks\.[a-z0-9_]+' "$locals" | cut -d. -f2 | sort -u)
    declared=$(just _tracks "$product" "{{release}}" | cut -d' ' -f1 | sort -u)

    if [[ -z $declared ]]; then
      echo "FAIL: $product: the manifest has no components for {{release}}" >&2
      fail=1
      continue
    fi

    missing=$(comm -23 <(printf '%s\n' "$used") <(printf '%s\n' "$declared"))
    if [[ -n $missing ]]; then
      echo "FAIL: $locals reads tracks the manifest omits for $product {{release}}:" >&2
      printf '  %s\n' $missing >&2
      fail=1
    fi

    unused=$(comm -13 <(printf '%s\n' "$used") <(printf '%s\n' "$declared"))
    if [[ -n $unused ]]; then
      echo "FAIL: the manifest defines tracks $locals never reads, so a cut would drop them:" >&2
      printf '  %s\n' $unused >&2
      fail=1
    fi
  done

  (( fail == 0 )) && echo "OK: manifest tracks match the modules for {{release}}"
  exit "$fail"

# Cut a release branch: freeze the charm tracks and default the risk to stable.
[group("Release")]
cut-release release base="main":
  #!/usr/bin/env bash
  set -euo pipefail

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "working tree is not clean" >&2
    exit 1
  fi

  # Fail before touching the repo if the manifest and the modules disagree.
  just check-tracks "{{release}}"

  git switch -c "track/{{release}}" {{base}}
  git switch -c "feat/cos-{{release}}"

  # A released product defaults to stable.
  for product in {{products}}; do
    sed -i -E 's/(default[[:space:]]*)= "edge"/\1= "stable"/' "terraform/$product/variables.tf"
  done

  # Freeze the charm tracks, re-attaching each comment in the old block to the
  # track it annotated so the diff shows changed values only.
  for product in {{products}}; do
    locals=terraform/$product/locals.tf

    # Captured, not written into the redirected awk below: a nested `just`
    # writing to a redirected stdout fails.
    frozen=$(just _tracks "$product" "{{release}}")
    printf '%s\n' "$frozen" >"$locals.frozen"

    # Comments in the old block, as "track<TAB>comment" lines.
    awk '
      /^  tracks = \{$/ { inside = 1; next }
      inside && /^  \}$/ { inside = 0; next }
      inside && /^[[:space:]]*#/ { comment = comment sep $0; sep = "\n"; next }
      inside && NF { if (comment != "") printf "%s\t%s\n", $1, comment; comment = ""; sep = "" }
    ' "$locals" >"$locals.notes"

    awk -v notes="$locals.notes" -v frozen="$locals.frozen" '
      BEGIN {
        while ((getline l < notes) > 0) {
          tab = index(l, "\t")
          noted[substr(l, 1, tab - 1)] = substr(l, tab + 1)
        }
        close(notes)
      }
      /^  tracks = \{$/ {
        print "  tracks = {"
        while ((getline l < frozen) > 0) {
          key = substr(l, 1, index(l, " = ") - 1)
          if (key in noted) print "    " noted[key]
          print "    " l
        }
        close(frozen)
        print "  }"
        inside = 1
        next
      }
      # The rendered block brings its own closing brace.
      inside && /^  \}$/ { inside = 0; next }
      !inside { print }
    ' "$locals" >"$locals.tmp"

    rm -f "$locals.notes" "$locals.frozen"
    mv -f "$locals.tmp" "$locals"
    echo "$locals: froze $(grep -cE '^    [a-z0-9_]+ = ' "$locals") tracks"
  done

  $terraform fmt -recursive terraform
  git commit -qam "feat: COS and COS Lite {{release}}"

  echo
  echo "Committed feat/cos-{{release}}. Then:"
  echo "  git push -u origin track/{{release}} feat/cos-{{release}} && gh pr create --base track/{{release}} --head feat/cos-{{release}} --title \"feat: COS and COS Lite {{release}}\" --fill"

# Add a released track to main's candidate quality-gate matrix.
[group("Release")]
prepare-main release:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "working tree is not clean" >&2
    exit 1
  fi

  git switch -c "chore/bump-main-{{release}}" main

  workflow=.github/workflows/quality-gates-candidate.yaml
  sed -i -E 's#(branch: \[[^]]*)\]#\1, track/{{release}}]#' "$workflow"
  echo "$workflow: added track/{{release}}"

  git commit -qam "chore: prepare main for release {{release}}"

  echo
  echo "Committed chore/bump-main-{{release}}. Then:"
  echo "  git push -u origin chore/bump-main-{{release}} && gh pr create --base main --head chore/bump-main-{{release}} --title \"chore: prepare main for release {{release}}\" --fill"
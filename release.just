# Product manifest that drives release metadata.
# Pinned to a commit for now; repin to a tag/sha (or main) once
# canonical/observability#503 merges.
manifest_url := "https://raw.githubusercontent.com/canonical/observability/03951447a73e0683b989c3069f6bc0bb5579b4d0/manifest.yaml"

# Cut a new release branch, retargeting the upgrade tests and freezing charm tracks.
[group("Release")]
cut-release release base="main":
  #!/usr/bin/env bash
  set -euo pipefail

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "working tree is not clean" >&2
    exit 1
  fi

  # MANIFEST is a local-file override, handy for testing.
  manifest=$(cat "${MANIFEST:-/dev/null}")
  [[ -n "$manifest" ]] || manifest=$(curl -fsSL "$manifest_url")

  # Each product's component tracks for this release, as "key<TAB>track" lines.
  components() {
    printf '%s' "$manifest" | product="$1" release="$release" yq -r '
      .products[] | select(.name == env(product))
      | .releases[] | select(.name == env(release))
      | .components // {}
      | to_entries | sort_by(.key)
      | .[] | "\(.key)\t\(.value)"
    '
  }

  # The tracks block for a product, aligned like `terraform fmt`.
  render_tracks() {
    local max=0 key value
    local -a keys=() values=()
    while IFS=$'\t' read -r key value; do
      [[ -n "$key" ]] || continue
      keys+=("$key"); values+=("$value")
      if (( ${#key} > max )); then max=${#key}; fi
    done < <(components "$1")
    (( ${#keys[@]} )) || {
      echo "error: $1: no components for $release in the manifest" >&2
      return 1
    }
    printf '  tracks = {\n'
    for key in "${!keys[@]}"; do
      printf '    %-*s = "%s"\n' "$max" "${keys[$key]}" "${values[$key]}"
    done
    printf '  }\n'
  }

  replace_tracks() {
    awk -v blockfile="$block" '
      BEGIN { while ((getline line < blockfile) > 0) block = block line "\n" }
      /^  tracks = \{/ { printf "%s", block; inside=1; next }
      inside && /^  \}$/ { inside=0; next }
      !inside { print }
    ' "$1" >"$1.tmp" && mv "$1.tmp" "$1"
  }

  # Fail before touching the repo if the release isn't in the manifest.
  for product in cos cos-lite; do render_tracks "$product" >/dev/null; done

  const="TRACK_$(echo "$release" | tr . _)_TF_FILE"
  git switch -c "track/$release" "$base"
  git switch -c "feat/cos-$release"

  # Each scenario upgrades from the previous track into this one.
  # Only COS and COS Lite have cross-track upgrade tests; cos-dev does not.
  for dir in tests/integration/cos/tls_* tests/integration/cos_lite/tls_*; do
    [[ -f "$dir/track-dev.tf" ]] || continue
    mv "$dir/track-dev.tf" "$dir/track-$release.tf"
    sed -i -E "s#//terraform/(cos-lite|cos)\"#//terraform/\1?ref=track/$release\"#" "$dir/track-$release.tf"
    sed -i -E "s/risk([[:space:]]*)= \"edge\"/risk\1= \"stable\"/" "$dir/track-$release.tf"
    sed -i -E \
      -e "s/track-dev\.tf/track-$release.tf/g" \
      -e "s/TRACK_DEV_TF_FILE/$const/g" \
      -e "s/test_deploy_to_track_dev/test_deploy_to_track/g" \
      -e "s/upgraded to track dev/upgraded to the next track/g" \
      "$dir"/test_upgrade_*.py
  done

  # The released product defaults to stable.
  sed -i -E "s/(default[[:space:]]*)= \"edge\"/\1= \"stable\"/" terraform/cos/variables.tf terraform/cos-lite/variables.tf

  # Freeze the charm tracks from the manifest.
  block=$(mktemp)
  trap 'rm -f "$block"' EXIT
  for product in cos cos-lite; do
    render_tracks "$product" >"$block"
    replace_tracks "terraform/$product/locals.tf"
    echo "terraform/$product/locals.tf: froze $(( $(wc -l <"$block") - 2 )) tracks"
  done

  git add -A tests/integration/cos tests/integration/cos_lite terraform/cos terraform/cos-lite
  git commit -q -m "feat: COS and COS Lite $release"

  echo
  echo "Committed feat/cos-$release. Then:"
  echo "  git push -u origin track/$release feat/cos-$release && gh pr create --base track/$release --head feat/cos-$release --title \"feat: COS and COS Lite $release\" --fill"
  echo "  run 'just prepare-main $release' and draft release notes"

# Prepare main for a released track: start its upgrade test from the new release.
[group("Release")]
prepare-main release:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "working tree is not clean" >&2
    exit 1
  fi

  git switch -c "chore/bump-main-$release" main

  # On main, replace the previous release's wrapper with this release's.
  for dir in tests/integration/cos/tls_* tests/integration/cos_lite/tls_*; do
    old=$(find "$dir" -maxdepth 1 -name 'track-*.tf' ! -name 'track-dev.tf' ! -name "track-$release.tf" -print -quit)
    [[ -n "$old" ]] || { echo "error: $dir: no upgrade source wrapper" >&2; exit 1; }
    old_version=$(basename "$old"); old_version=${old_version#track-}; old_version=${old_version%.tf}
    test_file=$(ls "$dir"/test_upgrade_*.py)
    old_const=$(grep -E "\"track-$old_version\.tf\"" "$test_file" | grep -oE '^[A-Z0-9_]+')
    [[ -n "$old_const" ]] || { echo "error: $test_file: no constant for track-$old_version.tf" >&2; exit 1; }
    mv "$old" "$dir/track-$release.tf"
    sed -i -E "s#ref=track/[0-9][0-9.]*#ref=track/$release#" "$dir/track-$release.tf"
    sed -i -E \
      -e "s/track-$old_version\.tf/track-$release.tf/g" \
      -e "s/$old_const/TRACK_${release//./_}_TF_FILE/g" \
      "$test_file"
    echo "$dir: $old_version -> $release"
  done

  workflow=.github/workflows/quality-gates-candidate.yaml
  sed -i -E "s#(branch: \[[^]]*)\]#\1, track/$release]#" "$workflow"
  echo "$workflow: added track/$release"

  git add -A tests/integration/cos tests/integration/cos_lite "$workflow"
  git commit -q -m "chore: prepare main for release $release"

  echo
  echo "Committed chore/bump-main-$release. Then:"
  echo "  git push -u origin chore/bump-main-$release && gh pr create --base main --head chore/bump-main-$release --title \"chore: prepare main for release $release\" --fill"

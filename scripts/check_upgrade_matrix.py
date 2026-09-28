#!/usr/bin/env python3
"""Check that each product release has an integration test for its upgrade source.

Reads product releases from canonical/observability's manifest.yaml and, for the
branch being checked, asserts that every release it upgrades from has a wrapper
under tests/integration/<product>/. The manifest is the source of truth for the
upgrade path; see canonical/observability#503.

The merge target is taken from GITHUB_BASE_REF (pull requests) or GITHUB_REF_NAME
(pushes), falling back to the checked-out branch. Override with --branch, and
point --manifest at a local file to avoid the network.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

import yaml

# TODO: pin to a tag/sha once canonical/observability#503 merges.
DEFAULT_MANIFEST = (
    "https://raw.githubusercontent.com/canonical/observability/"
    "feat/manifest-products/manifest.yaml"
)


def load_manifest(source: str) -> dict:
    if "://" in source:
        with urllib.request.urlopen(source) as response:
            return yaml.safe_load(response.read())
    return yaml.safe_load(Path(source).read_text())


def resolve_branch(override: str | None) -> str:
    if override:
        return override
    for env in ("GITHUB_BASE_REF", "GITHUB_REF_NAME"):
        if os.environ.get(env):
            return os.environ[env]
    out = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"],
        capture_output=True,
        text=True,
        check=True,
    )
    return out.stdout.strip()


def upgrade_sources(product: dict, branch: str) -> list[str]:
    """The releases a deployment on `branch` is tested upgrading FROM."""
    releases = [release["name"] for release in product["releases"]]
    if branch == "main":
        return [releases[-1]]
    match = re.fullmatch(r"track/(.+)", branch)
    if not match or match.group(1) not in releases:
        return []
    entry = product["releases"][releases.index(match.group(1))]
    return entry.get("upgrades_from", [])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", default=DEFAULT_MANIFEST)
    parser.add_argument("--branch", help="branch whose rules apply")
    args = parser.parse_args()

    products = load_manifest(args.manifest)["products"]
    branch = resolve_branch(args.branch)
    print(f"Checking upgrade tests for branch: {branch or '<unknown>'}")

    errors = []
    for product in products:
        test_dir = Path("tests/integration") / product["name"].replace("-", "_")
        for source in upgrade_sources(product, branch):
            if not list(test_dir.glob(f"*/track-{source}.tf")):
                errors.append(
                    f'{product["name"]}: branch "{branch}" upgrades from {source}, '
                    f"but {test_dir}/*/track-{source}.tf is missing"
                )

    if errors:
        print(f"\n{len(errors)} missing upgrade test(s):\n")
        for error in errors:
            print(f"  - {error}")
        return 1

    print("Every product release has a wrapper for each release it upgrades from.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

---
name: Cycle release
about: Track the progress of a cycle release for the Observability team.
title: "Cycle release YY.MM - Version X.Y"
labels: release
assignees: ''
---

Desired end state for each area of a cycle release. Please mark tasks as they are completed.

## 1. Scope and planning

- [ ] The artifacts (charms, snaps, rocks, etc.) and product versions (`X.Y`) are agreed upon.
- [ ] The release manifest (`manifest.yaml` in `canonical/observability`) has a pull request listing every rock, snap, and charm in scope, each with its repository, path, release version, and LTS flag, and every charm linked to the workload it deploys.

## 2. Workloads (rocks and snaps)

- [ ] Every in-scope rock has its new workload version defined in its repository, on the correct Ubuntu base, and the change is merged.
- [ ] Every in-scope rock is built and published through the OCI factory, with tags matching the release version.
- [ ] Every in-scope snap has its new version defined in its repository, and the change is merged.
- [ ] Every in-scope snap has a Snap Store track for the new version.
- [ ] Every in-scope snap is published to its new track.

## 3. Charms

- [ ] Every in-scope charm references the newly published workload version (rock image or snap track) on its `main` branch.
- [ ] Every in-scope charm builds against the new base (only if there is a new Ubuntu LTS; and in that case, Kubernetes charms replace the older base, while for machine charms it's additive).
- [ ] Every in-scope charm has a Charmhub track matching its new version.
- [ ] Every in-scope charm has a `track/<version>` git branch, cut from `main`, that publishes to its Charmhub track.
- [ ] Every in-scope charm's `track/<version>` branch has a generated `CHANGELOG.md` describing the changes since the previous track.
- [ ] Every in-scope charm's integration tests on the track branch target the new track and risk rather than `dev`/`edge`.

## 4. Documentation

Documentation lives in `docs/` and is versioned by branch: `main` is the staging area and the "latest" docs, and each `track/X.Y` branch publishes its own version (`documentation.ubuntu.com/observability/track-X.Y/`). Read the Docs keeps a release track as the default version, so `latest` is a preview of the release in progress. Author the updates on `main`; the `track/X.Y` branch is cut from `main` in step 5 and carries them.

### Pages

- [ ] `docs/release-notes.md` is updated to accurately describe the new release.
- [ ] `docs/reference/release-policy.md` contains a new row in the Releases table in reference to `X.Y`.
- [ ] `docs/reference/cos-components/index.md` is updated to accurately list the correct tracks, versions, and Terraform variable mappings for the new release.
- [ ] `docs/how-to/deploy-and-manage/install.md` uses the new module tags (`tf-cos-X.Y.n` / `tf-cos-lite-X.Y.n`) in the Terraform example and explanation.
- [ ] `docs/how-to/deploy-and-manage/upgrade.md`:
  - [ ] Has a new top section, "Migrate from COS `<previous>` to COS `X.Y`", covering both products, with *Applies to* notes. It covers the Terraform path (bump the module `ref`, then any state, variable, or data migration steps) and the non-Terraform path (`juju refresh` each charm to its new track).
  - [ ] Points to the previous release's upgrade guide on its own track docs for older migration paths, instead of repeating them.
  - [ ] Has its quick-links list at the top updated.
- [ ] Every tutorial in `docs/tutorial/` references the `X.Y` Terraform module tags and charm tracks.
- [ ] `main` contains all the documentation updates above, so the "latest" docs match the new release.

## 5. Product repository (`observability-stack`)

- [ ] A `track/X.Y` branch has been created, cut from `main` (it carries the documentation updates from step 4).
- [ ] On the `track/X.Y` branch, every product module pins each charm to the specific Charmhub track it ships on in this release, instead of `dev`, defaulting to the `stable` risk.
- [ ] The product has been successfully tested via Solutions QA.
- [ ] Terraform state migrations (`moved` blocks) cover every resource change since the previous release, so upgrades in place work.
- [ ] Integration tests cover fresh install and upgrade from the previous supported release(s) to this one, across every TLS mode (none, internal, external, full) and the supported Juju versions, for both COS and COS Lite.
- [ ] The documentation site (Read the Docs) has a version for `track/X.Y`, and it shows in the version switcher. @lucabello (or someone that has Read the Docs permissions)

## 6. Product release

- [ ] The `track/X.Y` branch has been added to the `terraform-release.yaml` workflow.
- [ ] The Terraform release workflow ran on the `track/X.Y` branch and created the product tags `tf-cos-X.Y.0` and `tf-cos-lite-X.Y.0`.

## 7. Announcement and close-out

- [ ] The release manifest pull request in `canonical/observability` is merged.
- [ ] The release is announced (Discourse and other channels), linking to release notes and upgrade guides. @lucabello

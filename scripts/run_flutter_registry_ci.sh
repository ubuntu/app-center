#!/usr/bin/env bash
# Reproduce the Flutter Customer Test Registry flow on Flutter main.
#
# This is the entry point behind `melos run run-flutter-registry-test`. It uses
# the Flutter main SDK from FVM's cache directly, so neither the repository's
# FVM selection nor the SDK that Melos selected is used or changed. The flow
# runs in a disposable copy of the worktree.
#
# Set REGISTRY_EVIDENCE_DIR to choose where logs and patches are saved, and
# REGISTRY_KEEP_TEMP=1 to keep the disposable checkout for debugging.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for tool in fvm git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: $tool is required by run_flutter_registry_ci.sh" >&2
    exit 2
  fi
done

log() {
  printf '[registry-ci] %s\n' "$*"
}

# Copy a worktree exactly as it is on disk: tracked files with uncommitted
# edits, new untracked files, and no files that were deleted or ignored.
snapshot_worktree() {
  local source="$1" destination="$2" index_dir index tree
  # A throwaway index lets git snapshot your worktree without touching the
  # index you have staged things in.
  index_dir="$(mktemp -d "${TMPDIR:-/tmp}/worktree-index.XXXXXX")"
  index="$index_dir/index"
  GIT_INDEX_FILE="$index" git -C "$source" add -A
  tree="$(GIT_INDEX_FILE="$index" git -C "$source" write-tree)"
  rm -rf "$index_dir"
  git -C "$source" archive --format=tar "$tree" | tar -xf - -C "$destination"
}

evidence_dir="${REGISTRY_EVIDENCE_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/app-center-registry-evidence.XXXXXX")}"
mkdir -p "$evidence_dir"
evidence_dir="$(cd "$evidence_dir" && pwd)"
export REGISTRY_EVIDENCE_DIR="$evidence_dir"

temp_root=""
# The phase being run, so a failure can be attributed. Only a failure in the
# "test" phase is a customer-test regression; earlier phases depend on tooling
# and network access that can fail intermittently.
phase="setup"
cleanup() {
  local status=$?
  set +e
  if [[ "$status" -ne 0 ]]; then
    echo "$phase" > "$evidence_dir/failed-phase.txt"
  fi
  if [[ -n "$temp_root" && -d "$temp_root/app-center/.git" ]]; then
    # Everything the update and test phases changed since the "prepare" commit.
    git -C "$temp_root/app-center" add -A
    git -C "$temp_root/app-center" diff --cached HEAD > "$evidence_dir/changes.patch"
  fi
  if [[ -n "$temp_root" ]]; then
    if [[ "${REGISTRY_KEEP_TEMP:-0}" == "1" ]]; then
      log "keeping temporary checkout at $temp_root"
    else
      rm -rf "$temp_root"
    fi
  fi
  log "evidence: $evidence_dir"
  exit "$status"
}
trap cleanup EXIT

log "installing and upgrading Flutter main"
fvm install main --skip-pub-get
sdk_root="${FVM_CACHE_PATH:-$HOME/fvm}/versions/main"
# Run outside the repository so the upgrade cannot touch its lockfile.
(cd "$evidence_dir" && "$sdk_root/bin/flutter" upgrade)
export PATH="$sdk_root/bin:$PATH"
log "selected SDK: $sdk_root"

flutter --version --machine | tee "$evidence_dir/flutter-version.json"
git -C "$repo_root" rev-parse HEAD > "$evidence_dir/app-center-revision.txt"

temp_root="$(mktemp -d "${TMPDIR:-/tmp}/app-center-registry.XXXXXX")"
checkout="$temp_root/app-center"
mkdir -p "$checkout"
log "copying tracked and worktree files to $checkout"
snapshot_worktree "$repo_root" "$checkout"

# A synthetic repository retains exactly what the registry's automatic update
# changed without copying the caller's history.
commit() {
  git -C "$checkout" add -A
  git -C "$checkout" \
    -c user.name="App Center registry CI" \
    -c user.email="app-center-registry-ci@localhost" \
    commit --allow-empty -qm "$1"
}
git -C "$checkout" init -q
commit "registry baseline"

cd "$checkout"

phase="prepare"
log "prepare"
dart scripts/customer_testing.dart prepare 2>&1 | tee "$evidence_dir/prepare.log"
commit "prepare"

# The registry's update contract: `flutter packages get`, then `dart fix --apply`.
phase="update"
for package in packages/app_center_ratings_client packages/app_center; do
  log "update $package"
  (cd "$package" && flutter packages get && dart fix --apply) 2>&1 |
    tee "$evidence_dir/update-$(basename "$package").log"
done

phase="test"
log "test"
dart scripts/customer_testing.dart test 2>&1 | tee "$evidence_dir/test.log"

log "customer registry flow passed"

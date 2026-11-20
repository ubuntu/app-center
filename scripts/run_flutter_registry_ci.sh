#!/usr/bin/env bash
# Reproduce the Flutter Customer Test Registry flow on Flutter main.
#
# This is the entry point behind `melos run run-flutter-registry-test`. It
# deliberately switches the local FVM selection to `main`, then uses that SDK
# directly instead of the SDK that Melos selected before running this script.
#
# Set REGISTRY_KEEP_TEMP=1 to keep the disposable checkout for debugging; the
# evidence directory is always retained.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

if ! command -v fvm >/dev/null 2>&1; then
  echo "error: fvm is required by run_flutter_registry_ci.sh" >&2
  exit 2
fi
if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required by run_flutter_registry_ci.sh" >&2
  exit 2
fi

log() {
  printf '[registry-ci] %s\n' "$*"
}

evidence_dir="${REGISTRY_EVIDENCE_DIR:-}"
if [[ -z "$evidence_dir" ]]; then
  evidence_dir="$(mktemp -d "${TMPDIR:-/tmp}/app-center-registry-evidence.XXXXXX")"
fi
mkdir -p "$evidence_dir"
evidence_dir="$(cd "$evidence_dir" && pwd)"
export REGISTRY_EVIDENCE_DIR="$evidence_dir"

fvm_backup="$(mktemp -d "${TMPDIR:-/tmp}/app-center-fvm-backup.XXXXXX")"
had_fvmrc=0
had_fvm_dir=0
if [[ -f "$repo_root/.fvmrc" ]]; then
  cp -a "$repo_root/.fvmrc" "$fvm_backup/.fvmrc"
  had_fvmrc=1
fi
if [[ -d "$repo_root/.fvm" ]]; then
  cp -a "$repo_root/.fvm" "$fvm_backup/.fvm"
  had_fvm_dir=1
fi

temp_root=""
cleanup() {
  local status=$?
  set +e

  if [[ -n "$temp_root" && -d "$temp_root" ]]; then
    if [[ "${REGISTRY_KEEP_TEMP:-0}" == "1" ]]; then
      log "keeping temporary checkout at $temp_root"
    else
      rm -rf "$temp_root"
    fi
  fi

  # Restore the exact files that existed before `fvm use main`. This avoids
  # overwriting unrelated edits with a `git checkout`, and also removes the
  # configuration if the caller did not have it.
  rm -f "$repo_root/.fvmrc"
  rm -rf "$repo_root/.fvm"
  if [[ "$had_fvmrc" == "1" ]]; then
    cp -a "$fvm_backup/.fvmrc" "$repo_root/.fvmrc"
  fi
  if [[ "$had_fvm_dir" == "1" ]]; then
    cp -a "$fvm_backup/.fvm" "$repo_root/.fvm"
  fi
  rm -rf "$fvm_backup"

  log "evidence: $evidence_dir"
  exit "$status"
}
trap cleanup EXIT

log "selecting Flutter main with fvm use main"
(
  cd "$repo_root"
  fvm use main --skip-pub-get
)

sdk_root="$(cd "$repo_root/.fvm/flutter_sdk" && pwd -P)"
sdk_bin="$sdk_root/bin"
export PATH="$sdk_bin:$PATH"
log "selected SDK: $sdk_root"

"$sdk_bin/flutter" --version --machine | tee "$evidence_dir/flutter-version.json"
app_center_sha="$(git -C "$repo_root" rev-parse HEAD)"
printf '%s\n' "$app_center_sha" > "$evidence_dir/app-center-revision.txt"
log "App Center revision: $app_center_sha"

temp_root="$(mktemp -d "${TMPDIR:-/tmp}/app-center-registry.XXXXXX")"
checkout="$temp_root/app-center"
mkdir -p "$checkout"
log "copying tracked and worktree files to $checkout"
(
  cd "$repo_root"
  git ls-files -z --cached --others --exclude-standard |
    tar --null -T - -cf -
) | tar -xf - -C "$checkout"

# A synthetic repository lets us retain exactly what the registry's automatic
# update changed without copying the caller's history or object database.
git -C "$checkout" init -q
git -C "$checkout" add -A
git -C "$checkout" \
  -c user.name="App Center registry CI" \
  -c user.email="app-center-registry-ci@localhost" \
  commit -qm "registry baseline"

cd "$checkout"

log "prepare"
set +e
dart run scripts/customer_testing.dart prepare 2>&1 | tee "$evidence_dir/prepare.log"
prepare_status=${PIPESTATUS[0]}
set -e

git status --porcelain > "$evidence_dir/prepare-status.txt"
git add -A
git diff --cached --stat > "$evidence_dir/prepare-diff-stat.txt"
git diff --cached > "$evidence_dir/prepare-diff.patch"
if [[ "$prepare_status" -ne 0 ]]; then
  log "prepare failed with exit $prepare_status"
  exit "$prepare_status"
fi
# `prepare` can legitimately change only ignored files. Create the base commit
# anyway so the update diff is isolated from the caller's checkout.
git -C "$checkout" \
  -c user.name="App Center registry CI" \
  -c user.email="app-center-registry-ci@localhost" \
  commit --allow-empty -qm "prepare"

update_status=0
for package in packages/app_center_ratings_client packages/app_center; do
  log "update $package"
  set +e
  (
    cd "$package"
    flutter packages get
    dart fix --apply
  ) 2>&1 | tee "$evidence_dir/update-$(basename "$package").log"
  package_status=${PIPESTATUS[0]}
  set -e
  if [[ "$package_status" -ne 0 ]]; then
    update_status=$package_status
    break
  fi
done

git status --porcelain > "$evidence_dir/update-status.txt"
git add -A
git diff --cached --stat > "$evidence_dir/update-diff-stat.txt"
git diff --cached > "$evidence_dir/update-diff.patch"
if [[ "$update_status" -ne 0 ]]; then
  log "update failed with exit $update_status"
  exit "$update_status"
fi
git -C "$checkout" \
  -c user.name="App Center registry CI" \
  -c user.email="app-center-registry-ci@localhost" \
  commit --allow-empty -qm "update"

log "test"
set +e
dart run scripts/customer_testing.dart test 2>&1 | tee "$evidence_dir/test.log"
test_status=${PIPESTATUS[0]}
set -e

git status --porcelain > "$evidence_dir/test-status.txt"
git add -A
git diff --cached --stat > "$evidence_dir/test-diff-stat.txt"
git diff --cached > "$evidence_dir/test-diff.patch"

if [[ "$test_status" -ne 0 ]]; then
  log "customer tests failed with exit $test_status"
  exit "$test_status"
fi

log "customer registry flow passed"

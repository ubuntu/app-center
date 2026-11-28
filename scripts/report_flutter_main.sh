#!/usr/bin/env bash
# Report a scheduled Flutter main customer test run on a GitHub issue.
#
# - A failure in the test phase opens one investigation issue, unless one is
#   already open.
# - A pass after a failed scheduled run comments on the open issue.
# - Anything else, including failures while setting up, reports nothing.
#
# The issue is never closed automatically; the team closes it.
#
# Called by .github/workflows/flutter-customer-registry.yaml with GH_TOKEN,
# GH_REPO, RESULT (the flutter-main job result), EVIDENCE_DIR, RUN_ID,
# APP_CENTER_SHA and BRANCH set.
set -euo pipefail

marker='<!-- flutter-main-investigation -->'
bot='github-actions[bot]'
run_url="https://github.com/$GH_REPO/actions/runs/$RUN_ID"

# The oldest open investigation issue opened by this workflow. Requiring the
# bot as author stops a pasted marker from suppressing or redirecting reports.
open_issue() {
  gh api --paginate "repos/$GH_REPO/issues?state=open&per_page=100" \
    --jq ".[] | select(.pull_request == null and .user.login == \"$bot\" and ((.body // \"\") | contains(\"$marker\"))) | .number" |
    sort -n | head -n 1
}

# The conclusion of the scheduled run before this one.
previous_conclusion() {
  gh run list --repo "$GH_REPO" --workflow flutter-customer-registry.yaml \
    --event schedule --branch "$BRANCH" --limit 5 \
    --json databaseId,conclusion \
    --jq "[.[] | select(.databaseId != $RUN_ID)][0].conclusion // \"\""
}

open_investigation() {
  local flutter_revision
  flutter_revision="$(jq -r '.frameworkRevision // "unavailable"' \
    "$EVIDENCE_DIR/flutter-version.json" 2>/dev/null || echo unavailable)"
  gh issue create --repo "$GH_REPO" \
    --title 'Flutter main investigation: App Center customer tests failing' \
    --body-file - <<EOF
$marker
The nightly Flutter main customer test run failed in the test phase.

- App Center commit: \`$APP_CENTER_SHA\`
- Flutter revision: \`$flutter_revision\`
- Workflow run: $run_url

Later failures do not open another issue. A comment is added when a nightly
run passes again; the team closes this issue once the cause is resolved.
EOF
}

issue="$(open_issue)"

case "$RESULT" in
  failure)
    phase="$(cat "$EVIDENCE_DIR/failed-phase.txt" 2>/dev/null || echo unknown)"
    if [[ "$phase" != test ]]; then
      echo "The run failed in the '$phase' phase, not the tests; nothing to report."
    elif [[ -n "$issue" ]]; then
      echo "Investigation #$issue is already open."
    else
      open_investigation
    fi
    ;;
  success)
    if [[ -z "$issue" ]]; then
      echo "No open investigation; nothing to report."
    elif [[ "$(previous_conclusion)" != failure ]]; then
      echo "The previous scheduled run did not fail; nothing to report."
    else
      gh issue comment "$issue" --repo "$GH_REPO" --body \
        "The nightly Flutter main customer test run passed again at App Center \`$APP_CENTER_SHA\`: $run_url"
    fi
    ;;
  *)
    echo "The run result was '$RESULT'; nothing to report."
    ;;
esac

---
name: contribute-to-repo
description: >
  Full workflow for committing changes and opening a pull request against the
  upstream app-center repository. Use this when asked to commit work, push, or
  open a PR on this project.
---

## Repo Layout

Discover the remotes dynamically:

```bash
git remote -v
```

Identify which remote points to the **upstream** (ubuntu/app-center) repo and which is the **fork**.
PRs must always target the **upstream** repo, opened from a fork branch.

## Step-by-step Workflow

### Publishing Rule

Any text that is published automatically to GitHub or another external system must disclose that it was AI-generated.

- Never post user-attributed text silently.
- If you are asked to publish a PR body, comment, review, or similar text automatically, include a short disclosure in the published text.
- Preferred disclosure: `*AI-authored.*`

### 1. Identify Co-authors

Ask the user if anyone should be co-authored on the commit (e.g., a pair-programming partner).
If so, look up their email from git history:

```bash
git log --format="%an <%ae>" | grep -i "<name>" | head -1
```

If no match is found, ask the user for the email directly.

If co-author trailers are relevant, always include the Copilot co-author trailer as well:

```text
Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### 2. Lint, Format, Generate Code, and Test

Before committing, run the formatter, code generator, and test suite using Melos:

```bash
# Generate code (freezed models, riverpod providers, l10n, etc.)
melos run generate

# Generate localizations
melos run gen-l10n

# Format Dart code (excluding generated files)
melos run format:exclude

# Run all tests
melos run test
```

Resolve any formatting issues, generation failures, or test failures before proceeding.

### 3. Stage and Commit

Stage all modified files and commit using **[Conventional Commits](https://www.conventionalcommits.org/)** format:

```
<type>(<scope>): <short summary>

<body — what changed and why>

Co-authored-by: <name> <email>
Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

Rule: if a human co-author is included, keep both trailers; do not replace the Copilot trailer.

**Types**: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`, `perf`, `style`

**Scopes** (examples): `snap`, `deb`, `ratings`, `snapd-watcher`, `manage`, `store`, `search`, `packagekit`, `explore`, `games`, `appstream`, `ui`

**Example commits:**
```
feat(snap): add support for classic snaps

Allow users to install classic snaps with user confirmation.

- Add classic snap detection
- Show consent dialog before installation
- Update snap model to track classic status

Fixes #123
```

```
fix(deb): resolve incorrect package version display

Version was showing installed version instead of available version.
Updated LocalDebInfo to correctly fetch version from AppStream metadata.
```

```bash
git add -A
git commit
```

### 4. Push to the Fork

Determine the current branch and your fork remote:

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
FORK_REMOTE=$(git remote -v | grep "push" | grep -v "ubuntu/app-center" | grep -oE "^[^ ]*" | head -1)

git push "$FORK_REMOTE" "$CURRENT_BRANCH"
```

### 5. Open a PR Against Upstream

Use the GitHub MCP tool with:
- `owner`: `ubuntu`
- `repo`: `app-center`
- `head`: `<your-username>:<current-branch>`
- `base`: `main`

If the PR body is posted automatically, append the disclosure line `*AI-authored.*`

Include a clear PR body:
- **What** changed (summary of commits, type of change: "Bug fix (non-breaking)", "New feature (non-breaking)", "Breaking change", "Documentation update")
- **Why** it was needed (context, issue number)
- **Notes** for reviewers (breaking changes, dependencies, etc.)

**PR body template:**

```markdown
## Description

Briefly describe what changed and why.

## Related Issue
Fixes #123

## Type of Change
Documentation update

## Checklist

- [ ] Tests pass (`melos run test`)
- [ ] Code formatted (`melos run format:exclude`)
- [ ] Generated code updated (`melos run generate`)
- [ ] Localizations updated (`melos run gen-l10n`)
- [ ] No breaking changes to public APIs
- [ ] PR follows Conventional Commits format
```

## Key Notes

- **Monorepo**: Changes may affect `packages/app_center/` or `packages/app_center_ratings_client/` or both
- **Generated files**: Never manually edit `.freezed.dart`, `.g.dart`, `.mocks.dart`, or `l10n/` files — run `melos run generate` and `melos run gen-l10n`
- **Dependencies**: Use `melos pub add <package>` to add packages to specific workspaces
- **Desktop-focused**: Always test on Linux desktop; other platforms may have different UX
- **Published text disclosure**: Any automatically posted PR body, comment, or review must disclose that it is AI-authored

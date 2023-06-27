#!/bin/bash

if [ -n "$(git status --porcelain)" ]; then
  git diff -- ':!**/pubspec.lock'
  outdated=$(git ls-files --modified -- ':!**/pubspec.lock')
  for f in $outdated; do
    echo "::warning ::$f may be outdated"
  done
  untracked=$(git ls-files --others --exclude-standard)
  for f in $untracked; do
    echo "::warning ::$f may be untracked"
  done
  if [ -n "$outdated" ] || [ -n "$untracked" ]; then
    exit 1
  fi
fi

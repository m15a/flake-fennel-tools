#!/usr/bin/env bash

set -euo pipefail

file=CHANGELOG.md

old="$(cat "$file" | grep -Em1 '^## \[[[:digit:]]+\.' | sed -E '1s|.*\[([^]]+)\].*|\1|')"
nix run sourcehut:~m15a/bump.fnl -- "$file" "$@"
git add "$file"
new="$(cat "$file" | grep -Em1 '^## \[[[:digit:]]+\.' | sed -E '1s|.*\[([^]]+)\].*|\1|')"

echo >&2 "Bump version: $old -> $new"

run() {
    echo >&2 "Run: $@"
    "$@"
}

if (( $(git status --short | wc -l) > 0 ))
then
    run git commit -m "release: $new"
    run git tag "v$new"
fi

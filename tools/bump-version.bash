#!/usr/bin/env bash

set -euo pipefail

file=CHANGELOG.md

bump "$file" "$@"
git add "$file"

version="$(cat "$file" | \
    grep -Em1 '^## \[[[:digit:]+\\.' | \
    sed -E '1s|.*\[([^]]+)\].*|\1|')"

git commit -m "release: $version"
git tag "v$version"

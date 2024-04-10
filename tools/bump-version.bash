#!/usr/bin/env bash

set -euo pipefail

changelog=CHANGELOG.md
flakehub_workflow=.github/workflows/flakehub-publish-rolling.yml

run() {
    echo >&2 "$*"
    "$@"
}

extract_version_from_changelog() {
    grep -Em1 '^## \[[[:digit:]]+\.' "$changelog" \
        | sed -E '1s|.*\[([^]]+)\].*|\1|'
}

old="$(extract_version_from_changelog)"
run nix run sourcehut:~m15a/bump.fnl -- --minor "$changelog"
new="$(extract_version_from_changelog)"

new_minor="$(echo $new | cut -d. -f2)"

sed -Ei "$flakehub_workflow" \
    -e "s|(rolling-minor: )[[:digit:]]+|\1$new_minor|"

if (( $(git status --short | wc -l) > 0 ))
then
    echo >&2 "Bump version: $old -> $new"
    run git add "$changelog" "$flakehub_workflow"
    run git commit -m "release: $new"
    run git tag "v$new"
fi

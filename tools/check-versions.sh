#!/usr/bin/env bash

set -uo pipefail

ANY_ERROR=false

check_version() {
    local name expected actual
    name="$1"
    expected="$(jq -r ".[\"$name\"]" nix/pkgs/versions.json 2>/dev/null)"
    actual="$2"

    # Strip git short commit hash if any.
    actual_without_hash="$(echo "$actual" | sed -E 's|-[0-9a-fA-F]+$||')"

    if [ "$expected" = "$actual_without_hash" ]
    then
        echo >&2 "[OK] $name: $actual"
    else
        echo >&2 "[ERROR] $name: expected $expected does not match actual $actual"
        false
    fi
}

check_version "fennel-stable" \
    "$(fennel --version 2>/dev/null | cut -d' ' -f2)"
test $? -eq 0 || ANY_ERROR=true

check_version "fennel-unstable" \
    "$(fennel-unstable --version 2>/dev/null | cut -d' ' -f2)"
test $? -eq 0 || ANY_ERROR=true

check_version "faith-stable" \
    "$(fennel --eval "(print (. (require :faith) :version))" 2>/dev/null)"
test $? -eq 0 || ANY_ERROR=true

check_version "faith-unstable" \
    "$(fennel --eval "(print (. (require :faith-unstable) :version))" 2>/dev/null)"
test $? -eq 0 || ANY_ERROR=true

check_version "fnlfmt-stable" \
    "$(fnlfmt --version 2>/dev/null | cut -d' ' -f3)"
test $? -eq 0 || ANY_ERROR=true

check_version "fnlfmt-unstable" \
    "$(fnlfmt-unstable --version 2>/dev/null | cut -d' ' -f3)"
test $? -eq 0 || ANY_ERROR=true

check_version "fenneldoc" \
    "$(grep 'FENNELDOC_VERSION =' "$FENNELDOC_PATH" 2>/dev/null | cut -d' ' -f3 | sed -E 's|\[\[([^]]+)]]|\1|')"
test $? -eq 0 || ANY_ERROR=true

check_version "fennel-ls-stable" \
    "$(grep -E '^## [[:digit:]]+\.[[:digit:]]+' "$FENNEL_LS_CHANGELOG_PATH" | head -n1 | sed -E 's|## ([^\s]+)|\1|')"
test $? -eq 0 || ANY_ERROR=true

check_version "fennel-ls-unstable" \
    "TODO"
test $? -eq 0 || ANY_ERROR=true

if [ "$ANY_ERROR" = true ]
then
    exit 1
else
    exit 0
fi

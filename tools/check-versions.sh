#!/usr/bin/env bash

set -uo pipefail

ANY_ERROR=false

check_version() {
    local name expected actual
    name="$1"
    expected="$2"
    actual="$3"

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

check_version "Fennel stable" \
    "$(jq -r '.["fennel-stable"]' nix/pkgs/versions.json 2>/dev/null)" \
    "$(fennel --version 2>/dev/null | cut -d' ' -f2)"
test $? -eq 0 || ANY_ERROR=true

check_version "Fennel unstable" \
    "$(jq -r '.["fennel-unstable"]' nix/pkgs/versions.json 2>/dev/null)" \
    "$(fennel-unstable --version 2>/dev/null | cut -d' ' -f2)"
test $? -eq 0 || ANY_ERROR=true

check_version "Faith stable" \
    "$(jq -r '.["faith-stable"]' nix/pkgs/versions.json 2>/dev/null)" \
    "$(fennel --eval "(print (. (require :faith) :version))" 2>/dev/null)"
test $? -eq 0 || ANY_ERROR=true

check_version "Faith unstable" \
    "$(jq -r '.["faith-unstable"]' nix/pkgs/versions.json 2>/dev/null)" \
    "$(fennel --eval "(print (. (require :faith-unstable) :version))" 2>/dev/null)"
test $? -eq 0 || ANY_ERROR=true

check_version "Fnlfmt stable" \
    "$(jq -r '.["fnlfmt-stable"]' nix/pkgs/versions.json 2>/dev/null)" \
    "$(fnlfmt --version 2>/dev/null | cut -d' ' -f3)"
test $? -eq 0 || ANY_ERROR=true

check_version "Fnlfmt unstable" \
    "$(jq -r '.["fnlfmt-unstable"]' nix/pkgs/versions.json 2>/dev/null)" \
    "$(fnlfmt-unstable --version 2>/dev/null | cut -d' ' -f3)"
test $? -eq 0 || ANY_ERROR=true

check_version "Fenneldoc" \
    "$(jq -r '.["fenneldoc"]' nix/pkgs/versions.json 2>/dev/null)" \
    "$(grep 'FENNELDOC_VERSION =' "$FENNELDOC_PATH" 2>/dev/null | cut -d' ' -f3 | sed -E 's|\[\[(.*)]]|\1|')"
test $? -eq 0 || ANY_ERROR=true

if [ "$ANY_ERROR" = true ]
then
    exit 1
else
    exit 0
fi

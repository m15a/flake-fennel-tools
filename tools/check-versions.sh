#!/usr/bin/env bash

set -uo pipefail

ANY_ERROR=false

check_version() {
    local name expected actual
    name="$1"
    expected="$2"
    actual="$3"
    if [ "$expected" = "$actual" ]
    then
        echo >&2 "[OK] $name: $expected"
    else
        echo >&2 "[ERROR] $name: expected $expected ≠ actual $actual"
        false
    fi
}

check_version "Fennel stable" \
    "$(grep fennel-stable nix/versions.nix | cut -d'"' -f2)" \
    "$(fennel --version 2>/dev/null | cut -d' ' -f2)"
test $? -eq 0 || ANY_ERROR=true

check_version "Fennel unstable" \
    "$(grep fennel-unstable nix/versions.nix | cut -d'"' -f2)" \
    "$(fennel-unstable --version 2>/dev/null | cut -d' ' -f2)"
test $? -eq 0 || ANY_ERROR=true

check_version "Faith stable" \
    "$(grep faith-stable nix/versions.nix | cut -d'"' -f2)" \
    "$(fennel --eval "(print (. (require :faith) :version))" 2>/dev/null)"
test $? -eq 0 || ANY_ERROR=true

check_version "Faith unstable" \
    "$(grep faith-unstable nix/versions.nix | cut -d'"' -f2)" \
    "$(fennel --eval "(print (. (require :faith-unstable) :version))" 2>/dev/null)"
test $? -eq 0 || ANY_ERROR=true

check_version "Fnlfmt stable" \
    "$(grep fnlfmt-stable nix/versions.nix | cut -d'"' -f2)" \
    "$(fnlfmt --version 2>/dev/null | cut -d' ' -f3)"
test $? -eq 0 || ANY_ERROR=true

check_version "Fnlfmt unstable" \
    "$(grep fnlfmt-unstable nix/versions.nix | cut -d'"' -f2)" \
    "$(fnlfmt-unstable --version 2>/dev/null | cut -d' ' -f3)"
test $? -eq 0 || ANY_ERROR=true

echo >&2 "[TODO] fenneldoc: check version consistency"

if [ "$ANY_ERROR" = true ]
then
    exit 1
else
    exit 0
fi

#!/usr/bin/env bash

set -euo pipefail

ANY_ERROR=false

FENNEL_STABLE_EXPECTED="$(grep fennel-stable nix/versions.nix | cut -d'"' -f2)"
FENNEL_UNSTABLE_EXPECTED="$(grep fennel-unstable nix/versions.nix | cut -d'"' -f2)"
FAITH_EXPECTED="$(grep faith nix/versions.nix | cut -d'"' -f2)"
FNLFMT_EXPECTED="$(grep fnlfmt nix/versions.nix | cut -d'"' -f2)"
# FENNELDOC_EXPECTED="$(grep fenneldoc nix/versions.nix | cut -d'"' -f2)"

FENNEL_STABLE_ACTUAL="$(nix run .#fennel-stable-luajit -- --version | cut -d' ' -f2)"
FENNEL_UNSTABLE_ACTUAL="$(nix run .#fennel-unstable-luajit -- --version | cut -d' ' -f2)"
FAITH_ACTUAL="$(nix run .#fennel-stable-luajit -- --eval "(print (. (require :faith) :version))")"
FNLFMT_ACTUAL="$(nix run .#fnlfmt -- --version | cut -d' ' -f3)"

if [ "$FENNEL_STABLE_EXPECTED" = "$FENNEL_STABLE_ACTUAL" ]
then
    echo >&2 "[OK] Fennel stable: $FENNEL_STABLE_ACTUAL"
else
    echo >&2 "[ERROR] Fennel stable: actual $FENNEL_STABLE_ACTUAL ≠ expected $FENNEL_STABLE_EXPECTED"
    ANY_ERROR=true
fi

if [ "$FENNEL_UNSTABLE_EXPECTED" = "$FENNEL_UNSTABLE_ACTUAL" ]
then
    echo >&2 "[OK] Fennel unstable: $FENNEL_UNSTABLE_ACTUAL"
else
    echo >&2 "[ERROR] Fennel unstable: actual $FENNEL_UNSTABLE_ACTUAL ≠ expected $FENNEL_UNSTABLE_EXPECTED"
    ANY_ERROR=true
fi

if [ "$FAITH_EXPECTED" = "$FAITH_ACTUAL" ]
then
    echo >&2 "[OK] faith: $FAITH_ACTUAL"
else
    echo >&2 "[ERROR] faith: actual $FAITH_ACTUAL ≠ expected $FAITH_EXPECTED"
    ANY_ERROR=true
fi

if [ "$FNLFMT_EXPECTED" = "$FNLFMT_ACTUAL" ]
then
    echo >&2 "[OK] fnlfmt: $FNLFMT_ACTUAL"
else
    echo >&2 "[ERROR] fnlfmt: actual $FNLFMT_ACTUAL ≠ expected $FNLFMT_EXPECTED"
    ANY_ERROR=true
fi

echo >&2 "[TODO] fenneldoc: check version consistency"

if [ "$ANY_ERROR" = true ]
then
    exit 1
else
    exit 0
fi

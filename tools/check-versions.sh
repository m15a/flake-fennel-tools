#!/usr/bin/env bash

set -euo pipefail

ANY_ERROR=false

FENNEL_STABLE_EXPECTED="$(grep fennel-stable nix/versions.nix | cut -d'"' -f2)"
FENNEL_UNSTABLE_EXPECTED="$(grep fennel-unstable nix/versions.nix | cut -d'"' -f2)"
FAITH_STABLE_EXPECTED="$(grep faith-stable nix/versions.nix | cut -d'"' -f2)"
FAITH_UNSTABLE_EXPECTED="$(grep faith-unstable nix/versions.nix | cut -d'"' -f2)"
FNLFMT_STABLE_EXPECTED="$(grep fnlfmt-stable nix/versions.nix | cut -d'"' -f2)"
FNLFMT_UNSTABLE_EXPECTED="$(grep fnlfmt-unstable nix/versions.nix | cut -d'"' -f2)"
# FENNELDOC_EXPECTED="$(grep fenneldoc nix/versions.nix | cut -d'"' -f2)"

FENNEL_STABLE_ACTUAL="$(fennel --version 2>/dev/null | cut -d' ' -f2)"
FENNEL_UNSTABLE_ACTUAL="$(fennel-unstable --version 2>/dev/null | cut -d' ' -f2)"
FAITH_STABLE_ACTUAL="$(fennel --eval "(print (. (require :faith) :version))" 2>/dev/null)"
FAITH_UNSTABLE_ACTUAL="$(fennel --eval "(print (. (require :faith-unstable) :version))" 2>/dev/null)"
FNLFMT_STABLE_ACTUAL="$(fnlfmt --version 2>/dev/null | cut -d' ' -f3)"
FNLFMT_UNSTABLE_ACTUAL="$(fnlfmt-unstable --version 2>/dev/null | cut -d' ' -f3)"

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

if [ "$FAITH_STABLE_EXPECTED" = "$FAITH_STABLE_ACTUAL" ]
then
    echo >&2 "[OK] faith stable: $FAITH_STABLE_ACTUAL"
else
    echo >&2 "[ERROR] faith stable: actual $FAITH_STABLE_ACTUAL ≠ expected $FAITH_STABLE_EXPECTED"
    ANY_ERROR=true
fi

if [ "$FAITH_UNSTABLE_EXPECTED" = "$FAITH_UNSTABLE_ACTUAL" ]
then
    echo >&2 "[OK] faith unstable: $FAITH_UNSTABLE_ACTUAL"
else
    echo >&2 "[ERROR] faith unstable: actual $FAITH_UNSTABLE_ACTUAL ≠ expected $FAITH_UNSTABLE_EXPECTED"
    ANY_ERROR=true
fi

if [ "$FNLFMT_STABLE_EXPECTED" = "$FNLFMT_STABLE_ACTUAL" ]
then
    echo >&2 "[OK] fnlfmt stable: $FNLFMT_STABLE_ACTUAL"
else
    echo >&2 "[ERROR] fnlfmt stable: actual $FNLFMT_STABLE_ACTUAL ≠ expected $FNLFMT_STABLE_EXPECTED"
    ANY_ERROR=true
fi

if [ "$FNLFMT_UNSTABLE_EXPECTED" = "$FNLFMT_UNSTABLE_ACTUAL" ]
then
    echo >&2 "[OK] fnlfmt unstable: $FNLFMT_UNSTABLE_ACTUAL"
else
    echo >&2 "[ERROR] fnlfmt unstable: actual $FNLFMT_UNSTABLE_ACTUAL ≠ expected $FNLFMT_UNSTABLE_EXPECTED"
    ANY_ERROR=true
fi

echo >&2 "[TODO] fenneldoc: check version consistency"

if [ "$ANY_ERROR" = true ]
then
    exit 1
else
    exit 0
fi

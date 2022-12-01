#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

$SCRIPT_DIR/watch.sh . bash -c "\"time crystal run --release part$1.cr < $2\""

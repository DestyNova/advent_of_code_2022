#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

$SCRIPT_DIR/watch.sh '*.cr' bash -c "\"time crystal run part$1.cr < $2\""

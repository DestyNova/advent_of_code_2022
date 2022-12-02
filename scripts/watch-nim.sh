#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

$SCRIPT_DIR/watch.sh '*.nim' bash -c "\"time nim --gc:orc -d:release r part$1.nim < $2\""

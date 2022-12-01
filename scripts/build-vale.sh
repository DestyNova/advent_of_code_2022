#!/usr/bin/env bash

rm -r ./target
~/code/vale/bin/valec build mymodule=part$1.vale --output_dir target

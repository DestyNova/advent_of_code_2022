#!/usr/bin/env bash

rm -r ~/.cache/nim/part2_r
nim c -d:release --gc:orc $1

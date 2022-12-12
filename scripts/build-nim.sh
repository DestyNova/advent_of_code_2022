#!/usr/bin/env bash

rm -r ~/.cache/nim/part2_*r
nim c -d:release --gc:orc $1

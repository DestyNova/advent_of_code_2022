#!/usr/bin/env bash

SUFFIX=${1:-"2"}

echo "\nBuilding (Crystal)..."
time crystal build --release part$SUFFIX.cr
mv part$SUFFIX part${SUFFIX}_crystal

echo "\nBuilding (Nim)..."
time nim c -d:release part$SUFFIX.nim
mv part$SUFFIX part${SUFFIX}_nim

# echo "\nBuilding (Vale)..."
# time valec build --release part$SUFFIX.vale
# mv part$SUFFIX part${SUFFIX}_vale
# 
# echo "\nBuilding (Ante)..."
# time ante build --release part$SUFFIX.ante
# mv part$SUFFIX part${SUFFIX}_ante

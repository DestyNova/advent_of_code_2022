#!/usr/bin/env bash

SUFFIX=${1:-"2"}

echo -e "\nBuilding (Crystal)..."
time ../scripts/build-crystal.sh part$SUFFIX.cr
mv part$SUFFIX part${SUFFIX}_crystal

echo -e "\nBuilding (Nim)..."
time ../scripts/build-nim.sh part$SUFFIX.nim
mv part$SUFFIX part${SUFFIX}_nim

# echo -e "\nBuilding (Vale)..."
# time valec build --release part$SUFFIX.vale
# mv part$SUFFIX part${SUFFIX}_vale
# 
# echo -e "\nBuilding (Ante)..."
# time ante build --release part$SUFFIX.ante
# mv part$SUFFIX part${SUFFIX}_ante

echo -e "\n\nBenchmarking..."

# NOTE: cargo install hyperfine
hyperfine --warmup 1 \
  "./part${SUFFIX}_crystal < input" \
  "./part${SUFFIX}_nim < input" \
  --export-json stats.json
  # "./part${SUFFIX}_vale < input" \
  # "./part${SUFFIX}_ante < input"

echo "Making plots..."
python3 ../scripts/plot_whisker.py stats.json -o runtime.png
# Try to reduce PNG size even though it doesn't matter...
optipng -o7 runtime.png

echo "\nMeasuring peak RSS (Crystal)..."
time -f "%K %t %M" ./part2_crystal < input

echo "\nMeasuring peak RSS (Nim)..."
time -f "%K %t %M" ./part2_nim < input

echo "\nRaw size (Crystal)"
stat -c "%s" part2.cr

echo "\nRaw size (Nim)"
stat -c "%s" part2.nim

echo "\nGzipped bytes (Crystal)"
<part2.cr gzip - | wc -c

echo "\nGzipped bytes (Nim)"
<part2.nim gzip - | wc -c

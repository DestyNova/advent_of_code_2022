#!/usr/bin/env bash

SUFFIX=${1:-"2"}

# NOTE: Clear Crystal build cache if it's been populated:
# rm -r ~/.cache/crystal/*advent-of-code*

echo -e "\nBuilding (Crystal)..."
time ../scripts/build-crystal.sh part$SUFFIX.cr
mv part$SUFFIX part${SUFFIX}_crystal

echo -e "\nBuilding (Nim)..."
time ../scripts/build-nim.sh part$SUFFIX.nim
mv part$SUFFIX part${SUFFIX}_nim

# echo -e "\nBuilding (Vale)..."
# time valec build --release part$SUFFIX.vale
# mv part$SUFFIX part${SUFFIX}_vale

# echo -e "\nBuilding (Ante)..."
# time ../scripts/build-ante.sh part$SUFFIX.an
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

echo -e "\nMeasuring peak RSS (Crystal)..."
/usr/bin/time -f "%M" ./part2_crystal < input

echo -e "\nMeasuring peak RSS (Nim)..."
/usr/bin/time -f "%M" ./part2_nim < input

echo -e "\nRaw size (Crystal)"
stat -c "%s" part2.cr

echo -e "\nRaw size (Nim)"
stat -c "%s" part2.nim

echo -e "\nGzipped bytes (Crystal)"
<part2.cr gzip - | wc -c

echo -e "\nGzipped bytes (Nim)"
<part2.nim gzip - | wc -c

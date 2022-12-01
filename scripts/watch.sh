#!/usr/bin/env bash

set -euo pipefail

SRC=$1
shift
CMD=$@

COLS=`tput cols`
HALF_COLS=$(expr $(expr $COLS - 6) / 2)

# AWK beauty

print_started() {
  awk "BEGIN {printf \"\n┌\"; for(i=0; i < $COLS - 3; i++) printf \"─\"; printf \"┐\n\n\";}"
}

print_success() {
  awk "BEGIN {printf \"\n└\"; for(i=0; i < $HALF_COLS; i++) printf \"─\"; printf \" ✅ \"; for(i=0; i < $HALF_COLS; i++) printf \"─\"; printf \"┘\n\n\";}"
}

print_fail() {
  awk "BEGIN {printf \"\n└\"; for(i=0; i < $HALF_COLS; i++) printf \"─\"; printf \" ❌ \"; for(i=0; i < $HALF_COLS; i++) printf \"─\"; printf \"┘\n\n\";}"
}

# actual thing

echo Watching $SRC
echo Command: $CMD
while sleep 2
do
  inotifywait -qq -r -e close_write,moved_to,move_self,modify $SRC
  date
  print_started

  bash -c "$CMD" && print_success || print_fail
done

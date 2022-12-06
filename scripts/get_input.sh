#!/usr/bin/env bash

DAY=$(basename $(pwd))

curl --cookie "session=$(<../../session.txt)" https://adventofcode.com/2022/day/$DAY/input > input

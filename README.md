# 🎄 Advent of Code 2022 🎄

A collection of (attempted) solutions for the [Advent of Code 2022](https://adventofcode.com/2022/) programming puzzles. I'm not sure how this is going to go, but I'll probably try to use the [Nim](https://nim-lang.org) and maybe [Crystal](https://crystal-lang.org) programming languages which are quite friendly and straightforward to work with.

I've mostly used Haskell in the past and really like it, but some puzzles required dynamic programming which is easy in impure procedural languages, but more complicated in Haskell -- finding a mutation-free solution can be very difficult, and working with the `ST` monad added a lot of noise and cognitive load for me. I'm sure with more practice that gets easier.

One thing I'm expecting to find more difficult in Nim/Crystal is complex input parsing, which was generally made easy and elegant with Haskell's amazing [Parsec](https://wiki.haskell.org/Parsec) which is included in the standard library.

## Previous challenges

* [2015](https://github.com/DestyNova/advent_of_code_2015) (working on these now in Picat)
* [2019](https://github.com/destynova/advent_of_code_2019) (unfinished, will resume later...)
* [2020](https://github.com/destynova/advent_of_code_2020) (mostly Haskell, one or two in Rust, Python and [zz](https://github.com/zetzit/zz)
* [2021](https://github.com/destynova/advent_of_code_2021) (mostly Haskell, with one in the magical [Picat](http://www.picat-lang.org)

## Current code stats with [cloc](https://github.com/AlDanial/cloc)

```
github.com/AlDanial/cloc v 1.90  T=0.10 s (1184.9 files/s, 323697.9 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
JSON                            14              0              0          27510
Nim                             47            614            386           2611
Markdown                        22            449              0            756
Crystal                         12             33              2            198
Python                           6             51             65            108
Bourne Shell                    10             36             14             74
Lua                              2             16             24             55
Ruby                             7              8             12             22
Solidity                         1              0              0             11
-------------------------------------------------------------------------------
SUM:                           121           1207            503          31345
-------------------------------------------------------------------------------
```

## Retrospectives

* Day 1: [Calorie Counting](https://github.com/DestyNova/advent_of_code_2022/blob/main/1)
* Day 2: [Rock Paper Scissors](https://github.com/DestyNova/advent_of_code_2022/blob/main/2)
* Day 3: [Rucksack Reorganization](https://github.com/DestyNova/advent_of_code_2022/blob/main/3)
* Day 4: [Camp Cleanup](https://github.com/DestyNova/advent_of_code_2022/blob/main/4)
* Day 5: [Supply Stacks](https://github.com/DestyNova/advent_of_code_2022/blob/main/5)
* Day 6: [Tuning Trouble](https://github.com/DestyNova/advent_of_code_2022/blob/main/6)
* Day 7: [No Space Left On Device](https://github.com/DestyNova/advent_of_code_2022/blob/main/7)
* Day 8: [Treetop Tree House](https://github.com/DestyNova/advent_of_code_2022/blob/main/8)
* Day 9: [Rope Bridge](https://github.com/DestyNova/advent_of_code_2022/blob/main/9)
* Day 10: [Cathode-Ray Tube](https://github.com/DestyNova/advent_of_code_2022/blob/main/10)
* Day 11: [Monkey in the Middle](https://github.com/DestyNova/advent_of_code_2022/blob/main/11)
* Day 12: [Hill Climbing Algorithm](https://github.com/DestyNova/advent_of_code_2022/blob/main/12)
* Day 13: [Distress Signal](https://github.com/DestyNova/advent_of_code_2022/blob/main/13)
* Day 14: [Regoith Reservoir](https://github.com/DestyNova/advent_of_code_2022/blob/main/14)
* Day 15: [Beacon Exclusion Zone](https://github.com/DestyNova/advent_of_code_2022/blob/main/15)
* Day 16: [Proboscidea Volcanium](https://github.com/DestyNova/advent_of_code_2022/blob/main/16)
* Day 17: [Pyroclastic Flow](https://github.com/DestyNova/advent_of_code_2022/blob/main/17)
* Day 18: [Boiling Boulders](https://github.com/DestyNova/advent_of_code_2022/blob/main/18)
* Day 19: [Not Enough Minerals](https://github.com/DestyNova/advent_of_code_2022/blob/main/19)
* Day 20: [Grove Positioning System](https://github.com/DestyNova/advent_of_code_2022/blob/main/20)
* Day 21: [Monkey Math](https://github.com/DestyNova/advent_of_code_2022/blob/main/21)
* Day 22: [?](https://github.com/DestyNova/advent_of_code_2022/blob/main/22)
* Day 23: [?](https://github.com/DestyNova/advent_of_code_2022/blob/main/23)
* Day 24: [?](https://github.com/DestyNova/advent_of_code_2022/blob/main/24)
* Day 25: [?](https://github.com/DestyNova/advent_of_code_2022/blob/main/25)

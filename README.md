# 🎄 Advent of Code 2022 🎄

My solutions for the [Advent of Code 2022](https://adventofcode.com/2022/) programming puzzles. Most of the first week's solutions were implemented in either [Nim](https://nim-lang.org), [Crystal](https://crystal-lang.org) or both, but after that I mostly stuck with Nim except for a few days where [Picat](http://www.picat-lang.org) came in handy (especially for its constraint solving abilities).

I've mostly used Haskell in the past and really like it, but some puzzles required dynamic programming which is easy in impure procedural languages, but more complicated in Haskell -- finding a mutation-free solution can be very difficult, and working with the `ST` monad added a lot of noise and cognitive load for me. I'm sure with more practice that gets easier.

One thing I found more awkward in Nim/Crystal is complex input parsing, which was usually easy and elegant thanks to Haskell's amazing [Parsec](https://wiki.haskell.org/Parsec), included in the standard library. After a couple of weeks of puzzling though, I learned to use Nim's `strscans/scanf` and `strutils/tokenize` functions which helped a lot. Picat seems a bit less polished from an input parsing point of view, so I mostly relied on `split`, although a few people mentioned to me that it has support for Prolog-style DCGs. I couldn't find much literature about how to use those properly in Picat, but I'll come back to them in future since I'll continue using Picat (and Nim) for at least the 2015 puzzles and maybe beyond.

## Previous challenges

* [2015](https://github.com/DestyNova/advent_of_code_2015) (working on these now in Picat)
* [2019](https://github.com/destynova/advent_of_code_2019) (unfinished, will resume later...)
* [2020](https://github.com/destynova/advent_of_code_2020) (mostly Haskell, one or two in Rust, Python and [zz](https://github.com/zetzit/zz)
* [2021](https://github.com/destynova/advent_of_code_2021) (mostly Haskell, with one in the magical [Picat](http://www.picat-lang.org)

## Current code stats with [cloc](https://github.com/AlDanial/cloc)

```
github.com/AlDanial/cloc v 1.90  T=0.12 s (1152.3 files/s, 302106.3 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
JSON                            16              0              0          28636
Nim                             55            781            470           3378
Markdown                        26            526              0            879
Crystal                         12             33              2            198
Python                           6             51             65            108
Bourne Shell                    11             38             14             77
Lua                              2             16             24             55
Ruby                             7              8             12             22
-------------------------------------------------------------------------------
SUM:                           135           1453            587          33353
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
* Day 22: [Monkey Map](https://github.com/DestyNova/advent_of_code_2022/blob/main/22)
* Day 23: [Unstable Diffusion](https://github.com/DestyNova/advent_of_code_2022/blob/main/23)
* Day 24: [Blizzard Basin](https://github.com/DestyNova/advent_of_code_2022/blob/main/24)
* Day 25: [Full of Hot Air](https://github.com/DestyNova/advent_of_code_2022/blob/main/25)

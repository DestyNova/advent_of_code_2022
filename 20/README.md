# Day 20: [Grove Positioning System](https://adventofcode.com/2022/day/20)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/20/part1.nim) (02:57:50, rank 3876), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/20/part2.nim) (03:01:14, rank 3357)*

Modulo logic...

## Part 1

This one was really confusing for me. I wasn't sure exactly what should happen in the edge cases like `[-1,0,0,0]` or `[0,0,0,5]` etc. I ended up with some really confusing conditions. Eventually I started echoing in some simple examples and reduced the logic to "determine target position, then the number of left/right swaps to get there".

## Part 2

The extension to part 2 was very trivial this time -- part 1 was really the hard part.

## Alternate implementations

(none)

## Thoughts

Too early in the morning for thinking about modulo and wrapping around a queue...

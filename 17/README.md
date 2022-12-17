# Day 17: [Pyroclastic Flow](https://adventofcode.com/2022/day/17)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/17/part1.nim) (02:01:58, rank 2970), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/17/part2.nim) (03:17:59, rank 1992)*

TETRIS! But only the piling up part.

## Part 1

As a 1980s gamer, I got a kick out of seeing the Tetris shapes. Part 1 was pretty straightforward but very easy to make small mistakes with offsets, order of updates, bounds-checking etc. At some point I was writing something to `newPos` instead of `newPos2`. That sort of messing.

## Part 2

The "now do it a JILLION TIMES" bit wasn't a big surprise, having previously encountered similar trickery in last year's Advent of Code. So I immediately guessed that there __must__ be repeats in the block patterns. So I added a check on every step that looks for a pattern of two consecutive rows I picked out arbitrarily, flagging the y position at which we found a match.

Sure enough, on the sample data this immediately turned out a match at every 53 rows with an offset of 37. Given this, some (considerable) amount of slow thinking and experimentation in GHCi produced a formula to go from target number of blocks (2022 for the sample) to a base height + remaining number of blocks `rem` (which will be in the range from 0 up to the pattern length - 1). Then it's just necessary to run the simulation for `RepeatOffset + rem` blocks to get the extra height to be added to the base.

## Alternate implementations

(none yet)

## Thoughts

This was a really fun puzzle -- I love the ones where there's a catch and you have to think carefully about the problem and its hidden characteristics. To me that's more fun than racing to implement the right graph search algorithm and dynamic programming cached representation.

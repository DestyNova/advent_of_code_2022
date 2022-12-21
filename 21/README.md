# Day 21: [Monkey Math](https://adventofcode.com/2022/day/21)
*Picat: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/21/part1.nim) (00:16:43, rank 1692), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/21/part2.nim) (00:53:29, rank 1577)*

Monkey magic.

## Part 1

Straight away this problem seemed pretty familiar -- I think there was a similar tree evaluation puzzle a year or two ago, with CPU instruction dependencies or something. It didn't take too long to parse the input into a map from monkey name to the list of tokens (either a single integer or the three-element list `[MonkeyA, Operation, MonkeyB]`). From there, solving the puzzle was a matter of solving "root"'s left and right hand sides by looking up `MonkeyA` and `MonkeyB` in the map and repeating the process recursively until all base cases (constants) are hit.

## Part 2

This was a cool extension to the part 1 problem. Having started with Picat, I decided to transform the recursive calculation to specify a series of constraints instead that would describe the complete expression in terms of the target variable `X` (passed down through the tree and eventually used when we reach the monkey "humn". Picat's pattern-matching function heads really help with this. Also, a slight change in thinking for the calculations was needed -- instead of the recursive `calc` calls returning a concrete result, they now receive a parameter `P` which is a domain variable that links the previous constraint expression to this one. That was a bit hard to wrap my head around but worked okay.

One thing to note is that the `sat` and `smt` modules produce incorrect results -- the output is 1 too high, and `sat` actually causes a segfault when run on the full input -- this may be to do with the large size of the domain variables (`X` is a 13-digit number).

## Alternate implementations

None, although I wouldn't mind coming back for a Nim implementation. Turning it into a constraint solving problem with Picat feels like cheating in a way, and I know other people did really clever things like rewriting the expression in terms of X or deriving it quickly using the slope of an initial error estimate. People are smart!

## Thoughts

This was a lot of fun.

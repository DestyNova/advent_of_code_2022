# Day 19: [Not Enough Minerals](https://adventofcode.com/2022/day/19)
*Picat: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/19/part1.nim) (04:27:49, rank 2586), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/19/part2.nim) (04:32:54, rank 1946)*

Day 16 part 3...

## Part 1

It became quickly apparently while reading the description that this was almost the same type of problem encountered on day 16: a planning problem. Naturally I jumped into coding this this same way (despite that my day 16 solutions were exceptionally slow). Before too long I ended up with a "working" DFS solution, but it took ages -- we're talking 10-30 minutes per blueprint, and we had 30 blueprints in the file. This could be parallelised but it just felt wrong to continue with that approach.

After a couple of hours, I realised that this problem can be formulated as an optimisation problem, since we know exactly how many steps to simulate: 24 in part 1, 32 in part 2.

I took the gamble that maybe Picat's constraint solvers would work on this problem if I encoded it properly. There is a `planner` module too but I don't know how to use it -- I might try that later because it could make things easier.

Anyway, it took another hour or so to encode the problem in Picat's domain constraint expressions. Along the way, I made the basic error of defining this timestep's ore values in terms of itself, rather than relative to the previous timestep's value. This results in error messages that are quite... terse. Like `error: failed/main`. So it takes some expertise to track down mistakes. I also learned how to make use of the implication constraint `X #=> Y`, which allowed me to get rid of some unwieldy and probably erroneous nested `cond` expressions.

Eventually when I got it running, I was astounded to discover that it produced the correct answer in about 22 seconds. A bit of optimisation brought it down to 12 seconds -- this consisted of the usual trick for Picat: define a range for every domain variable and try to reduce them their narrowest.

## Part 2

This is where the magic of Picat comes in: a tiny modification to the source code produced a program that outputs the correct result in about 9 seconds. My split time was about 5 minutes. Applying the same optimisations as in part 1 brought it down to about 6 seconds. I'm amazed at how easily Picat can take on problems like this, without having to specify how to search or provide heuristic guidance (which I tried in my Nim implementation, but obviously got something wrong).

Interestingly, for part 2 I didn't have much luck with Picat's `cp` solver, but relied on `sat` instead. There doesn't seem to be an easy way to tell ahead of time which solver should be used, but generally I'll start with cp, then sat, then mip, then smt (which has never really worked well for me in the past).

I think the solvers use branch-and-bound to cut down the state space of the search. That might be something to try with the Nim implementation.

## Alternate implementations

(none)

## Thoughts

Good fun, and I'll almost certainly reach for Picat next time a difficult optimisation/planning puzzle presents itself.

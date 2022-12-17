# Day 17: [Proboscidea Volcanium](https://adventofcode.com/2022/day/17)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/17/part1.nim) (02:43:52, rank 2605), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/17/part2.nim) (08:20:36, rank 3222)*

NAAAAAY!!!

## Part 1

Daaaaaamn this was tough. At first I wanted to switch to Picat since it's really good at optimisation and planning problems. However I couldn't figure out a straightforward way to represent this in Picat -- I feel good about its constraint solver, but never used the planner module before.

Eventually I decided to come back to the Picat version another day and just start with DFS in Nim. It quickly became apparent that this wouldn't complete in reasonable time, at least the way I'd created the graph. After stumbling through both parts I chatted with a few people and checked Reddit, where it seems the really fast solutions carefully constructed the graph by coalescing "useless" valves, or went further and:

1. constructed a distance graph between all valves (with Floyd-Warshall)
2. ran every possible permutation of valve turnings...
  * using the computed paths to determine the pressure released, and
  * pruning based on a heuristic similar to the `getApproximateOptimum` function I wrote in my BFS/A* implementation for part 2

Ultimately I ended up with an A*-ish implementation that prioritises states based on the sum of total pressured released and a heuristic approximation of the possible total future pressure released by opening the most valuable valve immediately, moving to the next most valuable, opening that, and so on.

This produced an answer for part 1 at least, but even then it's exceptionally slow. The compiled version takes 3 minutes and 40 seconds on my laptop.

## Part 2

For part 2, I extended my part 1 solution and tried to improve it by packing the `unturned` valve set into a 64-bit int, and a few other optimisations. It's also shockingly slow, though. I ran it for over an hour __twice__ and it eventually ran out of memory because the priority queue kept filling up with suboptimal solutions that were ranked highly by the heuristic. However if I got rid of that and just used the total pressure released to order states, the greedy algorithm still got stuck in bad parts of the state space.

After a long time, I tried adding some weighting to the comparator function (`<`) used by the priority queue, making the total actual pressure released slightly more important than the heuristic future approximation, and it produced a plausible result but kept spinning away. After a few minutes I pasted that number in and it turned out to be correct, which is lucky because I'd already tried 2 or 3 wrong answers before that point.

## Alternate implementations

I revisited the DFS + dyamic programming approach and split the player/elephant moves into two completely separate segments, searching the player's moves first, then resetting time to 26 and running with the elephant but keeping the updated pressure and unturned valve set. Unfortunately it still gets stuck and the DP table fills up very quickly and is eventually forcibly killed by the kernel's OOM checker.

I'll revisit it but not sure what to change, other than just trying one of the other approaches I read about.

## Thoughts

Definitely the most difficult puzzle. It's not that the concept of graph search is difficult; it's the actual details of how to represent the state in each vertex, which bits you care about, how to encode for storage in a DP table (e.g. some people managed to pack everything into an int, but I was already using one int for the valve set, another for the pressure released, an int8 for the current valve etc).

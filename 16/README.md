# Day 16: [Proboscidea Volcanium](https://adventofcode.com/2022/day/16)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/16/part1.nim) (02:43:52, rank 2605), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/16/part2.nim) (08:20:36, rank 3222)*

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

### DFS / DP

I revisited the DFS + dyamic programming approach and split the player/elephant moves into two completely separate segments, searching the player's moves first, then resetting time to 26 and running with the elephant but keeping the updated pressure and unturned valve set. Unfortunately it still gets stuck and the DP table fills up very quickly and is eventually forcibly killed by the kernel's OOM checker.

**Update 2022-12-17 10:08:** I added the heuristic evaluation function to the DFS/DP implementation, to little effect, then realised the heuristic evaluation function was bad: it was pairing up the highest pressure valves and having the elephant and player turn them in sequence. This made sense for the BFS approach where I was doing them in parallel, but for the DFS solution I'd separated out the player and elephant phases into different vertices. The heuristic value then should always have the character with the most remaining time turn valves. To do this I added an offset to the player of `26 - remaining minutes + 1`, so even with 26 minutes remaining, the elephant goes first and turns the highest-value valve (downsorted valve index `i=0`), followed by the player (turning the `(i+playerOffset)`-most valuable valve, if he had enough remaining minutes. We then increment `i` and continue until we've run out of time and/or valves.

This was still really slow, but produced the correct answer after about 30 seconds and eventually terminated, concluding that it was indeed correct, after 267 seconds.

### De-interleaved state in A* version

**Update 2022-12-18 19:14:** I tried adding the "de-interleaved" representation of vertices; that is, executing all the player's moves first, then resetting the clock and allowing the elephant to continue. That didn't work at all well with A* for some reason, but while working on it I noticed that there needs to be a `visited` set when doing BFS (or Dijkstra, or A*...) to avoid re-exploring the same states over and over! That's a really silly oversight on my part. I added that to both versions, and it massively sped up the previous implementation, so it found the correct result within a few seconds, but kept exploring the state space because it couldn't prove there wasn't something better out there. Might need to get rid of the heuristic bit, except... no, it needs that to know when a provably optimal result has been found.

### Interleaved version again

**Update... 1 hour later:** Ok! With another improvement to the `getNeighbours` function in `part2_astar_intpack` (the uninterleaved version), namely only allowing the player and elephant to both turn a valve if both (rather than either) of the valves have a flow rate greater than zero. It turns out that this significantly reduces the search space and enabled the program to find the correct result and terminate after 343 seconds. Disabling the heuristic evaluation function completely in the unexplored state prioritisation more than halved the time although I'm not quite sure why. I shaved a bit more off by dropping the accumulation of readable move labels since we don't need them, bringing us down to 129 seconds. This is still 1000x slower than other solutions that have been posted, so... more optimisations and alternate approaches may still come.
Sharing some of these optimisations brought the DFS/DP version down to 195 seconds.

### Picat, as constraint problem

**Update 2022-12-20 14:20:** After having some success with Picat for a similar day 19 problem, I spent ages encoding the day 16 problem for Picat's SAT solver, and it works for the sample input but produces a slightly too low result for my real input. And it takes about 6 minutes which is surprising given how it absolutely tore through the day 19 problem (which I was failing to solve in any kind of reasonable time in my Nim version).

Picat's constraint solving language is amazing, but it's not really well suited to action-selection problems, so there's a lot of awkward code in there using `matrix_element` etc to define the following state completely in terms of the current state and action. It reminds me a bit of using TLA+, where you have to specify the "afterstate" of every variable even if 90% of the state is assumed to stay unchanged. I'd prefer being able to say "the state at step T+1 will be the same as the state at step T, except with any changes implied by the following rules...".

But that's what Picat's `planner` module is for. So I'm going to give that a try and see if it's easier to use (for this), able to produce the correct answer, and able to do so in reasonable time. That's a lot to ask but hey.

### Picat, as planner problem

**Update 2022-12-26 02:41:** I fixed some issues and made some improvements to the Picat planner solution, thanks to some tips from Håkan Kjellerstrand. It doesn't work properly with overall negative costs, so I tried adding a constant value onto each move so that runs can't end up with zero or negative costs. This allows the planner to do a binary search for the best solution. However, it doesn't finish in reasonable time, even on the sample input. Strange.

### Nim, IDA*

I also tried using IDA* and it also can't solve the sample input quickly. Maybe straight BFS will do it though? What I implemented before was really A*, and it's possible the heuristic doesn't help.

**Update 2022-12-28 20:19:** I added a DP table to this (a fresh one for each "level" of IDA*) and it completes the search in 36 seconds IF you happen to specify exactly the correct result (2615 in my case) as the starting limit. Otherwise it absolute chews through RAM and takes ages.

### Nim, PEA* (2022-12-27)

I read about another "memory-concerned" A* variant called [Partial Expansion A*](https://www.aaai.org/Papers/AAAI/2000/AAAI00-142.pdf) and tried implementing it, since it's MUCH simpler than SMA* or SMA*+. It may be that I've left some important bits out, like removing and re-adding something in the "OPEN" set (aka priority queue).

**Update 2022-12-28 20:19:** I did some more work and think I've fixed the PEA* implementation. It works for the sample input and makes good progress toward the correct answer for the full input, while using relatively little memory but it's too slow. After about 50 minutes it was using about 300 MB of RAM and had found a solution of `2484`, so not too far away from the optimal `2615`. PEA* was designed specifically for use on the multiple-sequence genome alignment problem, which has a very high branching factor on the order of $2^d$, where $d$ represents the number of sequences to be matched, meaning it's common to have a branching factor of 128 or higher. In contrast, in this problem there are between 3-6 actions available at each timestep for each of the two players (human and elephant), meaning a branching factor between 9 and 36. Turning a valve with a flow rate of zero (which is actually most valves) is pointless, so in most states there will only be two meaningful actions (i.e. a combined branching factor of 4 for both players). Also, f-values are often the same, or very close together, for all neighbours (children) of a particular state, which means PEA* will still have to expand a lot of nodes. For these reasons I think PEA* is not a great tool for this type of problem. It's a pity I couldn't come up with a good way to implement SMA* / SMA*+ since they might have been better suited to this -- they behave like A* until hitting memory limits, then prune cleverly. But they're designed in a way that I struggled to understand and implement here (especially, storage and updating of parent nodes, and even popping the "worst" thing from a priority queue).

## Thoughts

Definitely the most difficult puzzle so far this year. It's not that the concept of graph search is difficult; it's the actual details of how to represent the state in each vertex, which bits you care about, how to encode for storage in a DP table (e.g. some people managed to pack everything into an int, but I was already using one int for the valve set, another for the pressure released, an int8 for the current valve etc).

I might come back to this one to try alternate approaches (and Picat).

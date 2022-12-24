# Day 23: [Blizzard Basin](https://adventofcode.com/2022/day/23)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/23/part1.nim) (03:31:25, rank 3155), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/23/part2.nim) (05:03:14, rank 3712)*

Now with added graph search!

## Part 1

Another plan/path optimisation problem. You'd think by now I'd have it figured out, but nope. I decided to try using Picat's planner module since I knew a bit more about it now, although my previous effort to use it wasn't very successful.
I decided to store the blizzards in a set of `(x,y,direction)` so that they could easily be updated and not interfere with each other.
It took a while to get the program to do anything -- Picat's main weakness is probably its error messages... for example, today I encountered these ones:

```
** Error  : invalid_dot_notation:[1|C]
```

This was caused by a typo, writing a tuple like (I,J.C) instead of (I,J,C). No line number in the error.

```
*** Undefined procedure: in/2
```

This turned out to be the line `if(membchk(C in "<>v^")) then`, because I'd started with `if(C in "<>v^") then` and "fixed" it by adding a call to `membchk` without swapping the `in` for a comma. Again though, no line number in the error message.

```
*** error(instantiation_error,(+)/2)
```

I think this was because I failed to specify a value for one or more of the `Cost` variables in the various action functions. Again, no line number in the error message, so finding the mistake was quite difficult.

Eventually I got the program to run on the sample input and produce the correct output, but it showed no signs of completing on the full input. After a few minutes of surprise and disappointment, I started writing a Nim implementation while waiting for the Picat version to complete, and eventually killed it because it was going nowhere, even with the addition of a heuristic function based on Manhattan distance to the goal.

The Nim version started off pretty quickly since I was able to adapt my A* implementation from day 16 and get something running. It was still really slow though, and ran out of memory quickly, just like my day 16 solution.
After adding a hack to clear the set of visited vertices, it about a minute to return the correct answer, and another minute to conclude that there were no better options.

## Part 2

The old favourite "now explode the action space by a factor of a jillion" flavour of part 2. I spent a long time trying to improve the heuristic function (although ultimately it turned out to be pretty straightforward), and trying to achieve the right balance of visited set size that would allow the program to make progress without running out of memory.

However, whatever I did, at some point the queue would suddenly start growing at a rapid pace -- maybe exponentially -- and the program would be killed before returning an optimal result. But by tweaking the priority queue comparator parameters I eventually got it to output the correct result and submit it, although the program wasn't ready to terminate.

After taking a short break, I realised that player's actions never interfere with the blizzard positions, so storing them in each vertex is unnecessary and very wasteful. Instead, I added a global `states` sequence, initially populated with the starting positions of the blizzards and lazily updated when we reach each new step. This allowed me to completely remove the blizzard state from the graph, so that vertices now only store the player position, the number of steps taken so far and the stage the player is in (where 0 = heading to the goal for the first time, 1 = heading back to the start to collect socks, and 2 = heading back to the end goal). This massively reduced memory consumption and allowed for a much greater size of the visited set, as well as greatly increased speed, producing the correct answer and terminating in just under 12 seconds.

The lesson: when doing a deep graph search, do everything you can to remove redundant information from the stored state, including recalculating it (but preferably calculating it once and caching).

## Alternate implementations

(none)

## Thoughts

Another fun one. Not a good result according to the scoreboard, but I'm starting to get the hang of these ones.

## Benchmarks

### Time (`-d:release --gc:orc`)

```
(too slow)
```

![Boxplot of runtime benchmark results](runtime.png)

### Summary

Program             | Compile time (s) | Mean runtime (ms) | Max RSS (kb) | Source bytes | Source gzipped
---                 | ---              | ---               | ---          | ---          | ---
part2_nim           |                  |                   | 241912       | 3622         | 1472

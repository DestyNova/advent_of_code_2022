# Day 12: [Hill Climbing Algorithm](https://adventofcode.com/2022/day/12)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/12/part1.nim) (02:31:07, rank 8292), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/12/part2.nim) (02:35:45, rank 7790)*

## Part 1

Before getting even halfway through the text I figured this was a Djikstra problem. I started writing a Nim program, and very short-sightedly just glanced at the `sets` API and noticed it didn't have a priority-queue "min-find" sort of function. I figured the problem might be small enough for solving with Floyd-Warshall instead, and spent aaaages trying to implement that. In the end, I got it working for the sample input, but the result it produced for the full input file was too low.

At this point I decided to take another look and see if there was something I could use in the Nim stdlib, and lo and behold, there's a `heapqueue` implementation that does exactly what I need. Whoops.

It didn't take too long from there to dump the Floyd-Warshall implementation (which had taken about 15-20 minutes to run) and replace it with a working implementation of Djikstra search, which returned the correct result in under 10 ms.

## Part 2

Well, if I'd gotten part 1 to work properly with Floyd-Warshall, part 2 would have been (relatively) trivial since it computes distances between all pairs of vertices. Although it would still take at least 15-20 minutes waiting for it to run.

Anyway, Djikstra's algorithm is pretty fast so looping through the graph and running the entire search again for matching source nodes (either 'S' or 'a') produced the correct result in 6.152 seconds.

## Alternate implementations

(none yet)

## Thoughts

I should probably be disappointed with my worst leaderboard place yet, but honestly I'm pretty happy with this one. The Djikstra implementation feels pretty neat. As usual Nim impresses with its conservative memory use: running the part 2 program on the full input (181x41 = 7421 vertices) used a max of 2300 kb RSS.

That Djikstra implementation might come in handy in future puzzles too. I'm tempted to try implementing another directed-with-no-cycles algorithm too.

## Benchmarks

### Time

```
Benchmark 1: ./part2_nim < input
  Time (mean ± σ):      6.152 s ±  0.027 s    [User: 6.146 s, System: 0.002 s]
  Range (min … max):    6.105 s …  6.198 s    10 runs
```

![Boxplot of runtime benchmark results](runtime.png)

### Summary

Program       | Compile time (s) | Mean runtime (ms) | Max RSS (kb) | Source bytes | Source gzipped
---           | ---              | ---               | ---          | ---          | ---
part2_crystal |                  |                   |              |              |    
part2_nim     |                  |                   |              |              |    

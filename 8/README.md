# Day 8: [Treetop Tree House](https://adventofcode.com/2022/day/8)
*Crystal: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/8/part1.nim) (00:30:36, rank 5666), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/8/part2.nim) (00:55:37, rank 5842)*

Column/row analytics in a grid of trees.

## Part 1

Don't forget that the nested array holding the grid of trees will be stored in row-major order.
Don't forget that the nested array holding the grid of trees will be stored in row-major order.
Don't forget that the nested array holding the grid of trees will be stored in row-major order.
Oh.

## Part 2

This got ugly pretty quick. I wanted to continue using a functional-ish approach, and did `map`/`take_while` thinking it would all be peachy. However I forgot that we actually want to count an immediately blocking tree as a distance of 1, but going off the edge doesn't count as 1 distance.
I couldn't for the life of me figure out a nice way to do this, and ended up adding a flag to check if we got blocked yet, setting it in the middle of the `take_while`. Awful, awful man.

## Alternate implementations

(none yet)

## Thoughts

Dunno what to say about this one. It's my worst ranking so far and really is an easy problem when you think about it. I probably should have stuck with Nim and just used plain old imperative for loops, which might have kept me away from the mess I made with `take_while`.

## Benchmarks

(none yet)

### Time

```
(no)
```

![Boxplot of runtime benchmark results](runtime.png)

### Summary

Program       | Compile time (s) | Mean runtime (ms) | Max RSS (kb) | Source bytes | Source gzipped
---           | ---              | ---               | ---          | ---          | ---
part2_crystal |                  |                   |              |              |    
part2_nim     |                  |                   |              |              |    

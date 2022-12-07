# Day 7: [No Space Left On Device](https://adventofcode.com/2022/day/7)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/7/part1.nim) (00:56:33, rank 5612), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/7/part2.nim) (01:05:07, rank 5300)*

Parse some commands to (conditionally) infer sizes in a directory tree.

## Part 1

Again I started with Nim and made use of the `strscans` module this time, although having to create a bunch of `vars` gets kind of ugly since they'll end up in a shared scope where they might not be relevant. It would be cool if they could somehow be bound within a macro body, sort of like using `map`.

This part took me ages because I couldn't think of a nice functional way to do it, due to the combination of recursion and stepping through the lines a variable amount. Maybe best would have been to return a tuple of `(Dir, int)` from `readDir`, which is probably how I'd have done it in Haskell.

## Part 2

Another reasonably small increment to the first program. Still took me nearly 10 minutes, but it wasn't that complex.

## Alternate implementations

### Crystal

(not yet)

## Reflections

I wasn't too happy with how this one went. Think I'll watch some livestream recordings of other people doing it and get some ideas before I do the Crystal version.

## Benchmarks

Computationally trivial again, so nothing much to see here.

### Time

```
(not yet)
```

![Boxplot of runtime benchmark results](runtime.png)

### Summary

Program       | Compile time (s) | Mean runtime (ms) | Max RSS (kb) | Source bytes | Source gzipped
---           | ---              | ---               | ---          | ---          | ---
part2_crystal | xxxxxx           | xxx               | xxxx         | xxx          | xxx
part2_nim     | xxxxxx           | xxx               | xxxx         | xxx          | xxx

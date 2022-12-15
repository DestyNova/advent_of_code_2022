# Day 14: [Regolith Reservoir](https://adventofcode.com/2022/day/14)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/14/part1.nim) (01:05:21, rank 4906), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/14/part2.nim) (01:21:24, rank 4816)*

## Part 1

It took me a while to figure out that... this one is pretty simple. It was just a case of representing the grid in memory. At first I collected the min/max bounds of the grid and tried to statically define a 2D array for speed (when will you learn not to optimise for speed at this point??) but Nim just would not let me, claiming I'd defined an invalid typespec, even though it looked like all the other examples I've seen.

So that wasted a few minutes before I gave up and stored it all in a `seq[seq[char]]`. This is definitely something that would have gone more smoothly in Haskell, since I'd just say it's a `List String` and move on. That said, I'd be generating a new grid on every timestep in Haskell, but... well it probably wouldn't matter in the slightest.

## Part 2

This again turned out to be a small extension of part 1, although I was initially struck by a fear that sand would flow out the sides and I'd have to either extend everything horizontally, or do some kind of heuristic grid calculation when things flow out the edges. Then I realised the pile of sand couldn't be wider than it is tall, and we know how tall it is, so I just extended the left and right edges to fit that. In fact I probably ~extended them too far -- I guess the X bounds should be (500 +/- maxY div 2)~. Maybe I'll update that now.

**Update:** No, that's a fail. A quick look at the pyramid of sand will show that its width is equal to twice its height + 1:

```
...o...
..ooo..
.ooooo.
```

## Alternate implementations

(none yet)

## Thoughts

Yet another mediocre performance where reading comprehension was possibly the most difficult part. Also, another reminder: start with dumb, easy-to-use data structures like `seq[seq[char]]`. In fact I could probably have even stored everything in a mutble hashtable and not even bothered finding the min/max bounds first. Nim is pretty fast.

**Update:** Out of curiosity I tried this out and indeed there's a 7x performance hit, but the program still runs in less than 100 ms in release mode, vs about 13 ms for the version with a `seq[seq[char]]`. Wow.

## Benchmarks

### Time (`-d:release --gc:orc`)

```
Benchmark 1: ./part2 input
  Time (mean ± σ):      11.1 ms ±   1.9 ms    [User: 10.2 ms, System: 0.6 ms]
  Range (min … max):     8.1 ms …  16.8 ms    349 runs
 
Benchmark 2: ./part2_hashtable input
  Time (mean ± σ):      81.3 ms ±   5.3 ms    [User: 79.3 ms, System: 1.7 ms]
  Range (min … max):    75.8 ms …  89.5 ms    37 runs
 
Benchmark 3: ./part2_array input
  Time (mean ± σ):      10.4 ms ±   1.6 ms    [User: 9.7 ms, System: 0.5 ms]
  Range (min … max):     7.1 ms …  15.7 ms    369 runs
 
Summary
  './part2_array input' ran
    1.07 ± 0.24 times faster than './part2 input'
    7.80 ± 1.28 times faster than './part2_hashtable input'
```

### Time (`-d:danger --gc:none`)

```
Benchmark 1: ./part2 input
  Time (mean ± σ):       7.7 ms ±   1.3 ms    [User: 6.6 ms, System: 0.9 ms]
  Range (min … max):     5.3 ms …  12.2 ms    403 runs
 
Benchmark 2: ./part2_hashtable input
  Time (mean ± σ):      70.1 ms ±   4.3 ms    [User: 67.7 ms, System: 2.2 ms]
  Range (min … max):    61.4 ms …  76.0 ms    40 runs
 
Benchmark 3: ./part2_array input
  Time (mean ± σ):       9.1 ms ±   1.3 ms    [User: 7.9 ms, System: 0.9 ms]
  Range (min … max):     6.3 ms …  13.3 ms    421 runs
 
Summary
  './part2 input' ran
    1.18 ± 0.26 times faster than './part2_array input'
    9.14 ± 1.59 times faster than './part2_hashtable input'
```

That's right; the array version is actually a bit slower in "danger" with GC turned off. In fact `gc:none` is slower than `gc:orc` -- about twice as slow when in release mode even, which is a bit surprising. I tested a few other combos of compiler settings, and found that the `markAndSweep` and `boehm` GC options also produce a slower array version in danger mode.

![Boxplot of runtime benchmark results](runtime.png)

### Summary

Program             | Compile time (s) | Mean runtime (ms) | Max RSS (kb) | Source bytes | Source gzipped
---                 | ---              | ---               | ---          | ---          | ---
part2_nim           | ~1.5             | 11.1              | 1836         | 2092         | 948
part2_nim_hashtable | ~1.5             | 81.3              | 5864         | 2089         | 948
part2_nim_array     | ~1.4             | 10.4              | 1940         | 2080         | 941

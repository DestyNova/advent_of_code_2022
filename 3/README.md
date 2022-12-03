# Day 3: [Rucksack Reorganization](https://adventofcode.com/2022/day/3)
*Crystal: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/3/part1.cr) (00:09:14, rank 2403), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/3/part2.cr) (00:16:06, rank 2588)*

A nice puzzle that felt easier than day 2.

Almost missed this one since my alarm was only set for 4:50am on weekdays. Luckily my sleep is still messed up, so I awoke at 2:30am and couldn't get back to sleep anyway.

## Part 1

I decided to attempt this in Crystal unless complicated parsing is necessary, since Nim has a nice `scanf` function in the `strscans` module, and Crystal doesn't seem to have a similar counterpart. But today's problem had a very simple input format, so I ploughed ahead.

Like before, I reached for a fairly imperative-style solution first since I was panicking and rushing a bit. After finishing part 2, I went back and tidied both parts a bit, deleting superfluous code, prints etc, and converted the top-level `each` with mutation to a `reduce` sum.

## Part 2

As is often the case in the first few days' puzzles, part 2 was more a reading comprehension/speed test, and the solution actually ended up being slightly shorter than part 1 since I didn't have to split each line into two halves anymore.

Instead I did a `reduce` over the set of chars in each line, intersecting them each time. I couldn't figure out a way to combine the `map` and `reduce` steps, because when you call `reduce` without an explicit initial value, it takes it from the input collection. But that's how `foldl1` in Haskell works, too:

```
λ> :t foldl
foldl :: Foldable t => (b -> a -> b) -> b -> t a -> b
λ> :t foldl1
foldl1 :: Foldable t => (a -> a -> a) -> t a -> a
```

## Alternate implementations

### Nim

(not done yet)

## Benchmarks

### Time

(Note the error about shell startup time -- unfortunately disabling the shell causes Nim programs to crash for some reason, so take these numbers with an even larger grain of salt)

```
(not yet)
```

![Boxplot of runtime benchmark results](runtime.png)

### Summary

Program | Compile time (s) | Mean runtime (ms) | Max RSS (kb) | Source bytes | Source gzipped
--- | --- | --- | --- | --- | ---
part2_crystal | compile | runtime | rss | bytes | gz
part2_nim | compile | runtime | rss | bytes | gz

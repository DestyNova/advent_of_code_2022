# Day 1: [Calorie Counting](https://adventofcode.com/2022/day/1)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/1/part1.nim) (00:07:24, rank 4144), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/1/part2.nim) (00:11:02, rank 4107)*

An easy warmup challenge.

## Part 1

The first few puzzles are always fairly easy, to get you warmed up and hooked before the difficulty ramps up. Since I'm not very familiar with Nim, I spent a bit of time figuring out how to deal with standard input, and ended up writing quite imperative-style code that reminds me of how I used to program in GFA Basic as a teenager.

## Part 2

At first I solved this with a minor extension to the part 1 code, but then took a few minutes to rewrite it into a more functional style. The ease with which you can write in both styles is something I really like about Nim.

## Alternate implementations

### Crystal

Rather than think hard, I just duplicated the Nim part 2 solution and translated it line-by-line into Crystal. I really like the clean, concise syntax this language provides. However I did notice that compile time in release mode is extremely long for such a simple program. Compile + runtime in Nim was 0.65 seconds, while Crystal took 12.84 seconds, basically all of which was compilation.

This might not be a problem in normal development, since you'd probably build in debug mode except when... releasing... but it was surprising to me nonetheless. Then again, Crystal requires fewer type annotations than Nim (which requires all functions to have explicitly typed signatures), so it probably has a different and more costly type inference mechanism. However, Haskell's Hindley-Milner inference also allows you to omit function signatures and it does release builds much quicker.

The resulting executable is about 10 times bigger in Crystal, although it's not **ludicrously** big:

File | Bytes
---  | ---
part2_crystal | 949600
part2_nim | 92520

Another interesting note: Nim caches builds, even if you update the source file timestamp. Maybe it stores a checksum/hash of the file -- in fact it indicates this in the compiler output:

```
Hint: gc: orc; opt: speed; options: -d:release
9903 lines; 0.015s; 8.637MiB peakmem; proj: /home/omf/code/advent-of-code/2022/1/part2.nim; out: /home/omf/.cache/nim/part2_r/part2_09B3CF9AC28D25C5791AB850DDFC9EC1C402C306 [SuccessX]
Hint: /home/omf/.cache/nim/part2_r/part2_09B3CF9AC28D25C5791AB850DDFC9EC1C402C306  [Exec]
```

That `09B3CF9AC28D25C5791AB850DDFC9EC1C402C306` looks like an SHA-1 hash since it's 40 hex chars long (160 bits), although I couldn't replicate it using `sha1sum part2.nim` so maybe some additional info is hashed along with the file contents.

### Vale

I started writing in Vale but quickly realised that there's almost no IO support in the stdlib yet. In fact the only relevant functions appear to be:

```
extern func __getch() int;
extern func stdinReadInt() int;
```

So... I'll skip Vale for now but will investigate more deeply (that is to say, I'll ask Vale's creator how to do it, since he's very responsive and helpful).

### Ante

Ante has more (extern) functions defined in the standard prelude for IO stuff, but... I can't figure out how to use them. I tried doing `fgets` with a mutable char buffer, but it wants a file handle. Stdin is a special file handle of `0`, but after some experimentation I wasn't able to cast an `i32` to `Ptr unit`, which is how the `File` type seems to be defined in Ante.

Maybe I'll come back to this one, but for now I'm not sure how to even read stdin...

## Benchmarks

Today's problem wasn't computationally difficult, so there's not much of interest in these benchmarks. Both implementations ran really quickly. I'm more interested to see the memory usage stats over time as we get to more complex problems: Crystal seems to be very memory efficient (at least, from the perspective of working with JVM languages for years), but Nim is extremely frugal, especially using the new ORC garbage collector, which seems to be more of a "statically generated deallocation + ref counter for cyclical pointers" thing.

Time:

```
Benchmark 1: ./part2_crystal < input
  Time (mean ± σ):       2.2 ms ±   0.5 ms    [User: 2.1 ms, System: 1.9 ms]
  Range (min … max):     1.3 ms …   3.8 ms    587 runs
 
Benchmark 2: ./part2_nim < input
  Time (mean ± σ):       0.9 ms ±   0.6 ms    [User: 0.9 ms, System: 0.5 ms]
  Range (min … max):     0.0 ms …   2.9 ms    1092 runs
 
Summary
  './part2_nim < input' ran
    2.50 ± 1.71 times faster than './part2_crystal < input'
```

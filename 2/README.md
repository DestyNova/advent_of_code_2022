# Day 2: [Rock Paper Scissors](https://adventofcode.com/2022/day/2)
*Nim: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/2/part1.nim) (00:13:08, rank 4768), [Part 2](https://github.com/DestyNova/advent_of_code_2022/blob/main/2/part2.nim) (00:20:35, rank 4777)*

Another easy but slightly more complicated puzzle. Didn't score well given I clicked into the puzzle exactly at the opening time (5:00am!), but hey.

## Part 1

This was another nice straightforward puzzle. I quickly ran into the limitations of Nim's lack of pattern-matching support when trying to do a `case (elfMove, myMove):`, only to get this error:

```
Error: selector must be of an ordinal type, float or string
```

That's a shame. To get around it, I did a very ugly thing and concatenated both values using string interpolation, then matched on the result. Oh well.

## Part 2

This was a fairly small extension of the initial solution, but I was able to drop the ugly strformat code and simplify the logic to three case expressions for the win/lose/draw moves + one more case expression to select whether we're winning, losing or drawing.

## Alternate implementations

### Crystal

I started with the Nim code, commented out, but found it neater to use `STDIN.each_line.reduce(0) { ... }`. Despite that the syntax is quite clean and compact, it still took more time than expected to write, although I'm not sure why. I was caught out for a moment by the `case ... when ...` expression's expectation that you follow each `when x` with a newline, and ended up inserting semicolons to keep the `when` and result expressions together on one line for pleasing visual brevity.

Apart from that I quite like it and the resulting code feels a bit more elegant and easier to read, despite that the dict creation and lookup might not be as optimal as the case expressions I used in Nim. Although maybe Crystal optimises that away. In any case, the program ran super fast in both languages, apart from the long compilation time in Crystal.

## Benchmarks

Again, there's not enough here to say that one language implementation is more efficient than the other. Also, since I solved things differently, I'd expect my Crystal solution to be a bit slower anyway.

### Time

(Note the error about shell startup time -- unfortunately disabling the shell causes Nim programs to crash for some reason, so take these numbers with an even larger grain of salt)

```
Benchmark 1: ./part2_crystal < input
  Time (mean ± σ):       2.8 ms ±   0.6 ms    [User: 2.3 ms, System: 2.2 ms]
  Range (min … max):     1.8 ms …   5.7 ms    652 runs
 
  Warning: Command took less than 5 ms to complete. Note that the results might be inaccurate because hyperfine can not calibrate the shell startup time much more precise than this limit. You can try to use the `-N`/`--shell=none` option to disable the shell completely.
 
Benchmark 2: ./part2_nim < input
  Time (mean ± σ):       1.1 ms ±   0.6 ms    [User: 1.0 ms, System: 0.5 ms]
  Range (min … max):     0.0 ms …   3.2 ms    1230 runs
 
  Warning: Command took less than 5 ms to complete. Note that the results might be inaccurate because hyperfine can not calibrate the shell startup time much more precise than this limit. You can try to use the `-N`/`--shell=none` option to disable the shell completely.
 
Summary
  './part2_nim < input' ran
    2.60 ± 1.53 times faster than './part2_crystal < input'
```

![Boxplot of runtime benchmark results](runtime.png)

### Summary

Program | Compile time (s) | Mean runtime (ms) | Max RSS (kb) | Source bytes | Source gzipped
--- | --- | --- | --- | --- | ---
part2_crystal | 15.64 | 2.8 | 3896 | 326 | 226
part2_nim | 1.06 | 1.1 | 1660 | 617 | 260

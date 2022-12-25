# Day 25: [Full of Hot Air](https://adventofcode.com/2022/day/25)
*Picat: [Part 1](https://github.com/DestyNova/advent_of_code_2022/blob/main/25/part1.nim) (00:37:37, rank 1663), Forgetting to click the star (00:39:20, rank 1451)*

## Part 1

A fairly easy finisher problem for the Advent of Code 2022 puzzles. I was pretty tired, with maybe 3 hours of sleep after staying up late wrapping the kids' presents, but thankfully today's puzzle was doable in that state. Really just a two-way base conversion task, but with the added quirk of the negative 1 and 2 values. At first I tried doing modulo 10 and mapping that way, but that was just silly. Instead, I should have just looked at the code I already wrote in the `parse_line` function -- the multiply and modulo step, that is -- and figured it out from there.

## Thoughts

I had a great time this year, even though I didn't score well (highest part 2 ranking was 1208 on day 10). Last year the theme for me was a combination of "how and when to use dynamic programming" and "help, how do you mutate state properly in Haskell??". This year planning graph search was a strong theme, showing up in at lesat 3 of the puzzles (16, 19 and 24).

Looking forward to getting back to the 2015 puzzles -- I'll probably continue this pattern of switching between Nim and Picat since that was quite enjoyable. For the 2016 set I might try learning something new and weird like BQN.

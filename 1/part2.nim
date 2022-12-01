import algorithm,math,sequtils,strutils

echo stdin
      .readAll
      .strip
      .split("\n\n")
      .mapIt(
        it
          .split
          .map(parseInt)
          .sum)
      .sorted(Descending)[0..2]
      .sum

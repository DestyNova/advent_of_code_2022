import algorithm,math,sequtils,strutils

echo stdin
      .readAll
      .split("\n\n")
      .mapIt(
        it
          .split()
          .mapIt(("0" & it).parseInt)
          .sum)
      .sorted(Descending)[0..2]
      .sum

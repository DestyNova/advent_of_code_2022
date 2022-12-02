proc getLoseMove(c: char): int =
  case c:
    of 'A': 3
    of 'B': 1
    of 'C': 2
    else: 0

proc getDrawMove(c: char): int =
  case c:
    of 'A': 1
    of 'B': 2
    of 'C': 3
    else: 0

proc getWinMove(c: char): int =
  case c:
    of 'A': 2
    of 'B': 3
    of 'C': 1
    else: 0

proc getOutcome*(c: char, me: char): int =
  case me:
    of 'X':
      getLoseMove(c)
    of 'Y':
      3 + getDrawMove(c)
    of 'Z':
      6 + getWinMove(c)
    else:
      -99999999

var score = 0

for line in stdin.lines:
  if line != "":
    let outcome = getOutcome(line[0], line[2])
    score += outcome

echo score

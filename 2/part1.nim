import strformat

proc getOutcome*(c: char, me: char): int =
  case &"{me}{c}":
    of "XC", "YA", "ZB": 6
    of "XA", "YB", "ZC": 3
    else: 0

proc getMovePoints(me: char): int =
  case me:
    of 'X': 1
    of 'Y': 2
    of 'Z': 3
    else: 0

var score = 0

for line in stdin.lines:
  if line != "":
    let outcome = getOutcome(line[0], line[2])
    let movePoints = getMovePoints(line[2])
    score += outcome + movePoints

echo score

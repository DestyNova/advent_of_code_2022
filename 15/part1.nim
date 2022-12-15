import std/[strformat, strscans, sets, tables, algorithm]

type Pos = (int,int)
type Interval = (int,int)
const TargetRow = 2000000

proc mergeSegments(segments: seq[Interval]): seq[Interval] =
  let s = segments.sortedByIt(it[0])
  var stack: seq[Interval]
  stack.add(s[0])
  for i in 1..s.len-1:
    if stack[^1][0] <= s[i][0] and s[i][0] <= stack[^1][1]:
      stack[^1][1] = max(stack[^1][1], s[i][1])
    else:
      stack.add(s[i])
  return stack

var
  sensors: HashSet[Pos]
  beacons: HashSet[Pos]
  detected: Table[Pos,Pos]
  emptySegments: seq[Interval]

for line in stdin.lines:
  var sx,sy,bx,by = 0
  discard scanf(line, "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sx, sy, bx, by)
  sensors.incl((sx,sy))
  beacons.incl((bx,by))
  detected[(sx,sy)] = (bx,by)

  let
    dx = bx - sx
    dy = by - sy
    d = dx.abs + dy.abs
  # does this beacon shed any light on the target row?
  if TargetRow in (sy - d)..(sy + d):
    let
      yToTarget = abs(TargetRow - sy)
      xRemaining = d - yToTarget
      x1 = sx - xRemaining + (if (sx - xRemaining, TargetRow) == (bx,by): 1 else: 0)
      x2 = sx + xRemaining - (if (sx + xRemaining, TargetRow) == (bx,by): 1 else: 0)

    if x1 <= x2:
      emptySegments.add((x1,x2))

let merged = mergeSegments(emptySegments)
var t = 0
for (a,b) in merged:
  t += b-a + 1

echo fmt"Total empty: {t}"

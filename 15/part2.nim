import std/[strformat, strscans, sets, tables, algorithm]

type Pos = (int,int)
type Interval = (int,int)
const
  MaxX = 4000000
  MaxY = 4000000

proc mergeSegments(segments: seq[Interval]): seq[Interval] =
  let s = segments.sortedByIt(it[0])
  var stack: seq[Interval]
  stack.add(s[0])
  for i in 1..s.len-1:
    if stack[^1][0] <= s[i][0] and s[i][0] <= stack[^1][1]:
      stack[^1][1] = max(stack[^1][1], s[i][1])
    else:
      stack.add(s[i])
  return stack.sortedByIt(it[0])

var
  beacons: HashSet[Pos]
  detected: Table[Pos,Pos]

for line in stdin.lines:
  var sx, sy, bx, by = 0
  discard scanf(line, "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sx, sy, bx, by)
  beacons.incl((bx,by))
  detected[(sx,sy)] = (bx,by)

for j in 0..MaxY:
  var emptySegments: seq[Interval]
  for k,v in detected:

    let
      (sx,sy) = k
      (bx,by) = v
      dx = bx - sx
      dy = by - sy
      d = dx.abs + dy.abs

    if j in (sy - d)..(sy + d):
      let
        yToTarget = abs(j - sy)
        xRemaining = d - yToTarget
        x1 = sx - xRemaining + (if (sx - xRemaining, j) == (bx,by): 1 else: 0)
        x2 = sx + xRemaining - (if (sx + xRemaining, j) == (bx,by): 1 else: 0)
      if x1 <= x2:
        emptySegments.add((x1,x2))

  let merged = mergeSegments(emptySegments)

  for z in 0..(len(merged)-2):
    let i = merged[z][1]+1
    if (merged[z+1][0] - i > 0) and (i,j) notin beacons:
      echo fmt"Possible beacon found at x={i}, y={j}, freq: {i*4000000 + j}"
      quit()

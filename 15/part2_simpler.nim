import std/[strformat, strscans, sugar, tables, algorithm]

type Pos = (int,int)
type Interval = (int,int)
const
  MaxX = 4000000
  MaxY = 4000000

var detected: Table[Pos,Pos]

for line in stdin.lines:
  var sx, sy, bx, by = 0
  discard scanf(line, "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sx, sy, bx, by)
  detected[(sx,sy)] = (bx,by)

for j in 0..MaxY:
  let intervals = collect(
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
          x1 = sx - xRemaining
          x2 = sx + xRemaining
        if x1 <= x2:
          (x1,x2)
    ).sortedByIt(it[0])

  var leftmostEmpty = intervals[0][0]
  for z in 0..(len(intervals)-2):
    let
      a = intervals[z]
      b = intervals[z+1]
      i = b[0]-1
    leftmostEmpty = max([leftmostEmpty, a[0], a[1]])
    if (leftmostEmpty < i):
      echo fmt"Possible beacon found at x={i}, y={j}, freq: {i*4000000 + j}"
      quit()

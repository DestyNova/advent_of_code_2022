import std/[sequtils, strformat, strutils, tables]

var
  minX = 500 # don't know the bounds yet
  maxX = 0
  minY = 0
  maxY = 0
  segments: seq[tuple[x1,y1,x2,y2: int]]

for line in stdin.lines:
  let coords = line.split(" -> ").mapIt(it.split(",").map(parseInt))
  # echo fmt"line: {line}"
  # echo coords
  for i in 0..coords.len-2:
    let
      x1 = coords[i][0]
      y1 = coords[i][1]
      x2 = coords[i+1][0]
      y2 = coords[i+1][1]

    minX = min(@[minX, x1, x2])
    minY = min(@[minY, y1, y2])
    maxX = max(@[maxX, x1, x2])
    maxY = max(@[maxY, y1, y2])

    segments.add((x1, y1, x2, y2))

# part 2: deeper
maxY = maxY + 2
minX = 500 - maxY
maxX = 500 + maxY

var g = initTable[(int,int), char]()

# part 2: add floor
for x in minX..maxX:
  g[(x,maxY)] = '#'

for (x1,y1,x2,y2) in segments:
    # add block for each discrete point along line
    if x1 == x2:
      # vertical line
      for y in min(y1, y2)..max(y1, y2): g[(x1,y)] = '#'
    else:
      # horizontal
      for x in min(x1, x2)..max(x1, x2): g[(x,y1)] = '#'

proc displayCave() =
  for j in minY..maxY:
    stdout.write('|')
    for i in minX..maxX:
      let c = g.getOrDefault((i,j))
      stdout.write(if c == '\0': '.' else: c)
    echo "|"

# do updates
var sand = 0

while true:
  # echo fmt"Units of sand dropped: {sand}"
  # displayCave()
  
  var
    x = 500
    y = 0
    overflowed = true

  while x in minX..maxX and y in minY..maxY-1:
    # try to insert 1 block of sand at x,y+1
    if (x,y+1) notin g:
      y = y+1
    # if not blank, then x-1,y+1
    elif (x-1,y+1) notin g:
      x = x-1
      y = y+1
    # if not blank, then x+1,y+1
    elif (x+1,y+1) notin g:
      x = x+1
      y = y+1
    # else came to rest, write final position
    else:
      g[(x,y)] = 'o'
      # echo fmt"placed sand at {x},{y}"
      overflowed = false
      break

  if overflowed:
    echo fmt"{sand} units of sand came to rest before overflowing into the void"
    quit()

  sand += 1

  if (x,y) == (500,0):
    echo fmt"Blocked the source point after dropping {sand} units of sand"
    quit()


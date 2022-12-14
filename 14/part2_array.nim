import std/[os, sequtils, strformat, strutils]

var
  minX = 500 # don't know the bounds yet
  maxX = 0
  minY = 0
  maxY = 0
  segments: seq[tuple[x1,y1,x2,y2: int]]

proc displayCave(g: seq[seq[char]]) =
  for j in minY..maxY:
    stdout.write('|')
    for i in minX..maxX:
      let c = g[j][i]
      stdout.write(if c == '\0': '.' else: c)
    echo "|"

for line in readFile(paramStr(1)).strip.splitLines:
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

var g: array[600, array[1000, char]]

# part 2: add floor
for x in minX..maxX:
  g[maxY][x] = '#'

for (x1,y1,x2,y2) in segments:
    # add block for each discrete point along line
    if x1 == x2:
      # vertical line
      for y in min(y1, y2)..max(y1, y2): g[y][x1] = '#'
    else:
      # horizontal
      for x in min(x1, x2)..max(x1, x2): g[y1][x] = '#'

# Run simulation
var sand = 0

while true:
  # echo fmt"Units of sand dropped: {sand}"
  # displayCave()
  
  var
    x = 500
    y = 0
    overflowed = true

  while x in minX..maxX and y in minY..maxY-1:
    # see if we can insert 1 block of sand at x,y+1
    if g[y+1][x] == '\0':
      y = y+1
    # if not, maybe x-1,y+1
    elif g[y+1][x-1] == '\0':
      x = x-1
      y = y+1
    # if not, maybe x+1,y+1
    elif g[y+1][x+1] == '\0':
      x = x+1
      y = y+1
    # otherwise it came to rest; write final position
    else:
      g[y][x] = 'o'
      overflowed = false
      break

  if overflowed:
    echo fmt"{sand} units of sand came to rest before overflowing into the void"
    quit()

  sand += 1

  if (x,y) == (500,0):
    echo fmt"Blocked the source point after dropping {sand} units of sand"
    quit()

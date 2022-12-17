import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

const W = 7
const PatternHeight = 2647
const PatternOffset = 446

type Coord = (int,int)

# parse

let jets = stdin.lines.toSeq[0]

# rock appears

let rocks = [
  @[(0,0),(1,0),(2,0),(3,0)],           # hline
  @[(1,0),(0,1),(1,1),(2,1),(1,2)],    # plus
  @[(2,0),(2,1),(2,2),(0,2),(1,2)],     # lefty L
  @[(0,0),(0,1),(0,2),(0,3)],           # vline
  @[(0,0),(1,0),(0,1),(1,1)],           # square
]
let rockHeights = [1,3,3,4,2]

echo "wat 1"
var
  # g = newSeq[array[0..6, bool]](64)
  g = newSeq[seq[bool]]()
  maxY = 0

proc printG() =
  for r in (0..maxY+4).toSeq.reversed():
    stdout.write('|')
    for c in 0..W-1:
      let x = g[r][c]
      stdout.write(if x: '#' else: '.')
    let asterisk = if (r-37) mod PatternHeight == 0: "*" else: ""
    echo fmt"|  {r} {asterisk}"

# extend g
let
  topRow = maxY + 4
  newRows = topRow - g.len
for j in 0..newRows:
  echo fmt"adding row #{j}"
  g.add(newSeq[bool](W))

echo fmt"g: {g.len}"
# add rock bits

# there's a collision if any point is out of bounds or occupied
proc collisions(rock: seq[Coord], pos: Coord): bool =
  for rc in rock:
    let
      col = pos[0]
      row = pos[1]
      x = col + rc[0]
      y = row - rc[1]

    if y < 0 or x < 0 or x >= W or g[y][x]: return true
  return false

# write rock to pos
proc writeRock(rock: seq[Coord], pos: Coord, solid: bool = true) =
  for rc in rock:
    # g[maxY + 4 - rc[1]] = array[0..6, bool]
    let
      col = pos[0]
      row = pos[1]
      x = col + rc[0]
      y = row - rc[1]

    # echo fmt"rock coord: {rc}"
    # echo fmt"writing to {x},{y}, row is: {g[row].len}"
    g[y][x] = solid

# try to move rock, return true if blocked or false otherwise
proc moveRock(rock: seq[Coord], oldPos: Coord, newPos: Coord): bool =
  # echo fmt"moving rock from {oldPos} to {newPos}"
  # erase old block
  writeRock(rock, oldPos, false)
  # echo "check collisions"
  if collisions(rock, newPos):
    # echo "yes collisions"
    writeRock(rock, oldPos)
    return true
  else:
    # echo "no collisions"
    writeRock(rock, newPos)
    return false

var jetIndex = 0

const RepeatOffset = 293
const RepeatLength = 1730
# sample input loops every 35 pieces, with offset 21
# let totalDrops = 21 + 35*2 # 0 = 37, 1 = 90, 2 = 143
let totalDrops = RepeatOffset + 0 # 10 extra height??
# let totalDrops = 1995 # (2022 - 21) div 35 = 57 with 6 remainder. 57 * 53 = 3021.
# first 21 blocks = height 37 (offsetHeight = 37, remeasure on input)
# adding remainder of 6 more blocks = 37 + (47-37 = 10 diff) = 47 ?????
# 47 + 3021 = 3068
#

let d = (1000000000000 - RepeatOffset) div RepeatLength
let rem = (1000000000000 - RepeatOffset) mod RepeatLength
let base = d * PatternHeight
let res = RepeatOffset + rem

echo fmt"base height: {base}, add height of {res} more blocks"
# for step in 0..293-1:
# for step in 0..(totalDrops + RepeatLength*2)-1:
for step in 0..res-1:
  # echo fmt"Step {step}"
  var
    rock = rocks[step mod 5]
    rockHeight = rockHeights[step mod 5]
    pos = (2, maxY + 2 + rockHeight)
    falling = true

  writeRock(rock, pos)
  # printG()

  while falling:
    # apply next jet (list repeats forever), if not blocked on that side
    let jet = jets[jetIndex mod jets.len]
    jetIndex += 1
    # echo fmt"applying jet {jet}"
    let newPos = case jet:
      of '>': (pos[0] + 1, pos[1])
      of '<': (pos[0] - 1, pos[1])
      else: raise newException(ValueError, fmt"Unknown jet dir: {jet}")

    if moveRock(rock, pos, newPos):
      # echo fmt"new pos: {pos} encountered collision, not moving horizontally"
      discard
    else:
      pos = newPos

    # printG()

    # apply gravity, if not blocked below
    # echo "Applying gravity"
    let newPos2 = (pos[0], pos[1]-1)

    if moveRock(rock, pos, newPos2):
      # echo fmt"new pos: {pos} encountered collision, not moving down"
      falling = false
    else:
      pos = newPos2

  # if step > 2020:
  #   printG()

  # update maxY
  let oldMaxY = maxY
  maxY = max(maxY, pos[1] + 1)
  # check for flat spot
  for j in max(1,oldMaxY-20)..maxY:
    var c = 0
    for i in 0..W-1:
      if g[j][i]: inc c
    # if c == W:
    #   echo fmt"WHOA, PARTY TIME AT STEP {step}, maxY: {maxY}, row: {j}"
    #   # 444, 541, 648, 769
    #   # quit()
    if g[j] == @[true,true,true,false,true,true,true] and g[j-1] == @[true,true,true,true,true,true,true]:
      echo fmt"POSSIBLE PARTY TIME AT STEP {step}, maxY: {maxY}, row: {j}"
  # echo fmt"pos now: {pos}. old max y: {oldMaxY}, new: {maxY}"
  for j in oldMaxY..maxY:
    # echo "adding 1 row"
    g.add(newSeq[bool](W))

printG()
echo fmt"Height after {totalDrops} rocks: {maxY}, mod 35 = {totalDrops mod 35}, / 35 = {totalDrops div 35}"
echo fmt"Total height: {base + maxY}"

# now repeating: 445, 3092, 5739, 8386, 11033, 16327, 18974

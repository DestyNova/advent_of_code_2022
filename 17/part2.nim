import std/[algorithm, sequtils, strformat]

const W = 7
const PatternHeight = 2647
const PatternOffset = 446

type Coord = (int,int)

let jets = stdin.lines.toSeq[0]

let rocks = [
  @[(0,0),(1,0),(2,0),(3,0)],           # hline
  @[(1,0),(0,1),(1,1),(2,1),(1,2)],     # plus
  @[(2,0),(2,1),(2,2),(0,2),(1,2)],     # lefty L
  @[(0,0),(0,1),(0,2),(0,3)],           # vline
  @[(0,0),(1,0),(0,1),(1,1)],           # square
]
let rockHeights = [1,3,3,4,2]

var
  g = newSeq[seq[bool]]()
  maxY = 0

proc printG() =
  for r in (0..maxY+4).toSeq.reversed():
    stdout.write('|')
    for c in 0..W-1:
      let x = g[r][c]
      stdout.write(if x: '#' else: '.')
    let asterisk = if (r-PatternOffset) mod PatternHeight == 0: "*" else: ""
    echo fmt"|  {r} {asterisk}"

let
  topRow = maxY + 4
  newRows = topRow - g.len
for j in 0..newRows:
  g.add(newSeq[bool](W))

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
    let
      col = pos[0]
      row = pos[1]
      x = col + rc[0]
      y = row - rc[1]

    g[y][x] = solid

proc moveRock(rock: seq[Coord], oldPos: Coord, newPos: Coord): bool =
  # echo fmt"moving rock from {oldPos} to {newPos}"
  # erase old block
  writeRock(rock, oldPos, false)
  if collisions(rock, newPos):
    writeRock(rock, oldPos)  # blocked; restore old block
    return true
  else:
    writeRock(rock, newPos)
    return false

var jetIndex = 0

const RepeatOffset = 293
const RepeatLength = 1730
const TargetBlocks = 1000000000000
# sample input loops every 35 pieces, with offset 21
# let totalDrops = 21 + 35*2 # 0 = 37, 1 = 90, 2 = 143
# let totalDrops = 1995 # (2022 - 21) div 35 = 57 with 6 remainder. 57 * 53 = 3021.
# first 21 blocks = height 37 (offsetHeight = 37, remeasure on input)
# adding remainder of 6 more blocks = 37 + (47-37 = 10 diff) = 47 ?????
# 47 + 3021 = 3068

let d = (TargetBlocks - RepeatOffset) div RepeatLength
let rem = (1000000000000 - RepeatOffset) mod RepeatLength
let base = d * PatternHeight
let res = RepeatOffset + rem

echo fmt"base height: {base}, add height of {res} more blocks"
for step in 0..res-1:
  # echo fmt"Step {step}"
  var
    rock = rocks[step mod 5]
    rockHeight = rockHeights[step mod 5]
    pos = (2, maxY + 2 + rockHeight)
    falling = true

  writeRock(rock, pos)

  while falling:
    # apply next jet (list repeats forever), if not blocked on that side
    let jet = jets[jetIndex mod jets.len]
    jetIndex += 1
    let newPos = case jet:
      of '>': (pos[0] + 1, pos[1])
      of '<': (pos[0] - 1, pos[1])
      else: raise newException(ValueError, fmt"Unknown jet dir: {jet}")

    if moveRock(rock, pos, newPos):
      # echo fmt"new pos: {pos} encountered collision, not moving horizontally"
      discard
    else:
      pos = newPos

    # echo "Applying gravity"
    let newPos2 = (pos[0], pos[1]-1)
    if moveRock(rock, pos, newPos2):
      falling = false
    else:
      pos = newPos2

  # if step > 2020: printG()

  # update maxY
  let oldMaxY = maxY
  maxY = max(maxY, pos[1] + 1)
  # check for repeats
  for j in max(1,oldMaxY-4)..maxY:
    if g[j] == @[true,true,true,false,true,true,true] and g[j-1] == @[true,true,true,true,true,true,true]:
      echo fmt"POSSIBLE PARTY TIME AT STEP {step}, maxY: {maxY}, row: {j}"
  # echo fmt"pos now: {pos}. old max y: {oldMaxY}, new: {maxY}"
  for j in oldMaxY..maxY:
    # echo "adding 1 row"
    g.add(newSeq[bool](W))

# printG()
echo fmt"Total height: {base + maxY}"
# now repeating at: 445, 3092, 5739, 8386, 11033, 16327, 18974

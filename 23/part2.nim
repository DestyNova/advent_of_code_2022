import std/[strformat, strutils, sugar, tables, sets, sequtils]

let
  input = stdin.readAll.split("\n\n")
  g = input[0].splitLines
  h = g.len

type
  Coord = (int,int)
  Dir = enum N,NE,E,SE,S,SW,W,NW

proc getOffset(d: Dir): (int,int) =
  case d:
    of N:  ( 0,-1)
    of NE: ( 1,-1)
    of E:  ( 1, 0)
    of SE: ( 1, 1)
    of S:  ( 0, 1)
    of SW: (-1, 1)
    of W:  (-1, 0)
    of NW: (-1,-1)

const checkOrder = [(N,[N,NE,NW]),(S,[S,SE,SW]),(W,[W,NW,SW]),(E,[E,NE,SE])]

var
  elves: HashSet[Coord]

proc addOffset(source: Coord, dir: Dir): Coord =
  let
    (x,y) = source
    (dx,dy) = getOffset(dir)
  (x+dx, y+dy)

# read initial elf locations
for j in 0..h-1:
  for i in 0..g[j].len-1:
    case g[j][i]:
      of '#': elves.incl((i+1,j+1))
      else: continue

proc reportElves(elves: HashSet[Coord], elf: Coord = (high(int), high(int))) =
  var
    minX = high(int)
    minY = high(int)
    maxX = low(int)
    maxY = low(int)

  for (x,y) in elves:
    if x < minX: minX = x
    if x > maxX: maxX = x

    if y < minY: minY = y
    if y > maxY: maxY = y

  for j in minY..maxY:
    for i in minX..maxX:
      stdout.write(if (i,j) in elves: (if (i,j) == elf: 'X' else: '#') else: '.')
    echo ""
  echo ""
  echo fmt"top left: {(minX, minY)}, bottom right: {(maxX,maxY)}"
  # count rectangle area
  let area = (maxX-minX+1) * (maxY-minY+1)
  # subtract num elves
  echo fmt"area: {area} - {elves.len} = {area - elves.len}"

proc nobodyAround(elf: Coord, elves: HashSet[Coord]): bool =
  let (x,y) = elf
  for j in -1..1:
    for i in -1..1:
      if (i,j) == (0,0): continue
      if (x+i,y+j) in elves: return false
  return true

var
  moved = true
  step = 0

while moved:
  # generate movement proposals
  # elf' from elf movements. N elves can propose moving to the same space.
  var proposedMoves: Table[Coord, seq[Coord]]
  for elf in elves:
    if not nobodyAround(elf, elves):
      for j in 0..4:
        let (dir,checkDirs) = checkOrder[(step+j) mod 4]
        # are all those dirs free?
        if not checkDirs.anyIt(addOffset(elf, it) in elves):
          let dest = addOffset(elf, dir)
          proposedMoves[dest] = proposedMoves.getOrDefault(dest) & @[elf]
          # reportElves(elves, elf)
          break

  # update all valid elves
  moved = false
  for d,movers in proposedMoves:
    if movers.len == 1:
      let mover = movers[0]
      elves.excl(mover)
      elves.incl(d)
      moved = true

  step += 1
  # reportElves(elves)

# find min/max coords of elves
# reportElves(elves)

echo fmt"Step: {step}"

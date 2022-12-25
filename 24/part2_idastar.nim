import std/[strformat, strutils, sets, tables]

type
  Coord = (int,int)
  Blizzard = (int,int,char)
  State = HashSet[Blizzard]
  Vertex = (int,int,int,int)  # player (x,y), num moves, stage 0/1/2

const Inf = high(int)
const Dirs = {'<': (-1,0), '>': (1,0), '^': (0,-1), 'v': (0,1)}.toTable
var
  w, h: int
  states: seq[State]

proc applyOffset(a: Coord,b: Coord): Coord =
  let
    (i,j) = a
    (dx,dy) = b
    i2 = i + dx + 2*w
    j2 = j + dy + 2*h
  (i2 mod w, j2 mod h)

proc getOffset(d: char): Coord = Dirs[d]

# cache all previously generated blizzard states since there'll be a reasonable finite number of them
proc step(i: int): State =
  if states.len <= i:
    var g2: State

    for b in states[i-1]:
      let
        (i,j,d) = b
        (i2,j2) = applyOffset((i,j),getOffset(d))
      g2.incl((i2,j2,d))
    states.add(g2)
    g2
  else:
    states[i]

proc getNeighbours(v: Vertex): seq[Vertex] =
  let
    (i,j,steps,stage) = v
    blizzards2 = step(steps+1)
    startPoint = (0,-1)
    endPoint = (w-1,h)

  var vs = newSeq[Vertex]()

  if stage >= 3: return vs # already reached the end

  # wait or move
  for (dx,dy) in [(0,0),(1,0),(-1,0),(0,1),(0,-1)]:
    let
      p = (i + dx, j + dy)
      (i2,j2) = p
      validSpace = i2 >= 0 and i2 < w and j2 >= 0 and j2 < h
      occupied = (i2,j2,'<') in blizzards2 or (i2,j2,'>') in blizzards2 or (i2,j2,'^') in blizzards2 or (i2,j2,'v') in blizzards2

    if validSpace and not occupied: vs.add((i2,j2,steps+1,stage))
    elif p == startPoint and stage == 1: vs.add((i2,j2,steps+1,stage+1))
    elif p == endPoint and stage != 1: vs.add((i2,j2,steps+1,stage+1)) # reached endPoint
    elif p == (i,j) and not occupied: vs.add((i,j,steps+1,stage))  # wait

  return vs

proc getApproximateOptimum(v: Vertex): int =
  let
    (i,j,_,stage) = v
    x = if stage == 1: i else: w-i-1
    y = if stage == 1: j+1 else: h-j
  x + y + max(0,(2-stage)*(w-1 + h+1))

proc dfs(start: Vertex, limit: int): int =
  let
    (i,j,moves,stage) = start
    f = moves + getApproximateOptimum(start)
    isGoal = (i,j) == (w-1,h) and stage == 3

  if isGoal: return -moves
  if f > limit: return f

  var minMoves = high(int)
  for u in getNeighbours(start):
    # echo fmt"dfs, recursing into {u}"
    let uF = dfs(u, limit)
    if uF < 0: return uF  # reached goal
    elif uF < minMoves: minMoves = uF

  minMoves

# IDA*
proc search(start: Vertex): int =
  for i in 1..1000:
    let r = dfs(start, i-1)
    echo fmt"IDA* round {i}, min f: {r}"
    if r < 0:
      return -r

  raise newException(ValueError, "Couldn't find solution within desired bounds.")

# parse
var blizzards: HashSet[Blizzard]
var j = 0
for line in stdin.lines:
  w = line.len-2
  h = j
  if line[2] == '#': continue
  for i in 0..line.len-1:
    if line[i] in "<>^v":
      blizzards.incl((i-1,j,line[i]))
  inc j

states.add(blizzards)
let s0: Vertex = (0,-1,0,0)
echo fmt"neighbours of near-end node: {getNeighbours((2,2,0,2))}"
echo fmt"initial approximate optimum: {getApproximateOptimum(s0)}"
echo fmt"Optimal result: {search(s0)}"

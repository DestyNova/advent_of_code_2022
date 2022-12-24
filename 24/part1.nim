import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

type
  Coord = (int,int)
  Blizzard = (int,int,char)
  State = HashSet[Blizzard]
  Vertex = (int,int,int,State)  # player (x,y), num moves, blizzards

const Inf = high(int)
const Dirs = {'<': (-1,0), '>': (1,0), '^': (0,-1), 'v': (0,1)}.toTable
var w, h: int

proc applyOffset(a: Coord,b: Coord): Coord =
  let
    (i,j) = a
    (dx,dy) = b
    i2 = i + dx + 2*w
    j2 = j + dy + 2*h
  (i2 mod w, j2 mod h)

proc getOffset(d: char): Coord = Dirs[d]

proc step(state: State): State =
  var g2: State

  for b in state:
    # echo b
    let
      (i,j,d) = b
      (i2,j2) = applyOffset((i,j),getOffset(d))
    g2.incl((i2,j2,d))
  g2

proc getNeighbours(v: Vertex): seq[Vertex] =
  let
    (i,j,steps,blizzards) = v
    blizzards2 = step(blizzards)

  var vs = newSeq[Vertex]()

  # echo fmt"exploring neighbours of {v}"
  # wait is safe if at start point, just step
  if (i,j) == (0,-1): vs.add((i,j,steps+1,blizzards2))

  # move
  for (dx,dy) in [(0,0),(1,0),(-1,0),(0,1),(0,-1)]:
    let
      p = (i + dx, j + dy)
      (i2,j2) = p
      validSpace = i2 >= 0 and i2 < w and j2 >= 0 and j2 < h
      occupied = (i2,j2,'<') in blizzards2 or (i2,j2,'>') in blizzards2 or (i2,j2,'^') in blizzards2 or (i2,j2,'v') in blizzards2

    # echo fmt"p: {p}, valid: {validSpace}, occupied: {occupied}, blizzards2: {blizzards2}"
    if validSpace and not occupied: vs.add((i2,j2,steps+1,blizzards2))

  return vs

proc getApproximateOptimum(v: Vertex): int =
  let (i,j,_,_) = v
  w-i-1 + h-j-1

# greedy approximation...
proc `<`(a, b: Vertex): bool =
  # a[2] >= b[2]
  let
    aPossible = getApproximateOptimum(a)
    bPossible = getApproximateOptimum(b)
  aPossible < bPossible

proc bfs(start: Vertex): (int, seq[string]) =
  var
    minMoves = Inf
    bestMoves: seq[string] = @[]
    q = initHeapQueue[Vertex]()
    visited = initHashSet[Vertex]()
    t = 0

  q.push(start)

  while q.len > 0:
    let
      v = q.pop
      (i,j,moves,_) = v
      bestPossible = moves + getApproximateOptimum(v)

    if t mod 1000 == 0:
      let n = q.len
      echo fmt"Step {t}: queue size: {n}, minMoves: {minMoves}, visited len: {visited.len}, current guess: {bestPossible}"
      if visited.len >= 39000:
        echo "Clearing visited set."
        visited.clear()
    inc t

    if moves < minMoves and (i,j) == (w-1,h-1):
      minMoves = moves
      echo fmt"new minMoves: {minMoves}, bestPossible: {bestPossible}"

    if bestPossible < minMoves:
      for u in getNeighbours(v):
        if u notin visited:
          q.push(u)
          visited.incl(u)

  (minMoves, bestMoves)

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

let s0: Vertex = (0,-1,0,blizzards)
echo fmt"s0: {s0}"
echo fmt"w,h: {w}, {h}, neighbours of start node: {getNeighbours(s0)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(s0)}"
let (moves, _) = bfs(s0)
echo moves+1

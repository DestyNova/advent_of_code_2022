import std/[strformat, strutils, sets, tables, deques]

type
  Coord = (int,int)
  Blizzard = (int,int,char)
  State = HashSet[Blizzard]
  Hazards = seq[seq[bool]]
  Vertex = (int,int,int,int)  # player (x,y), num moves, stage 0/1/2

const Dirs = {'<': (-1,0), '>': (1,0), '^': (0,-1), 'v': (0,1)}.toTable
var
  w, h: int
  states: seq[State]
  hazards: seq[Hazards] = newSeq[Hazards](1)

proc applyOffset(a: Coord,b: Coord): Coord =
  let
    (i,j) = a
    (dx,dy) = b
    i2 = i + dx + 2*w
    j2 = j + dy + 2*h
  (i2 mod w, j2 mod h)

proc getOffset(d: char): Coord = Dirs[d]

# cache all previously generated blizzard states since there'll be a reasonable finite number of them
proc step(i: int): Hazards =
  if states.len <= i:
    var
      bs: State
      blocked: Hazards

    for j in 0..h-1: blocked.add(newSeq[bool](w))

    for b in states[i-1]:
      let
        (i,j,d) = b
        (i2,j2) = applyOffset((i,j),getOffset(d))
      bs.incl((i2,j2,d))
      blocked[j2][i2] = true
    states.add(bs)
    hazards.add(blocked)
    blocked
  else:
    hazards[i]

proc getNeighbours(v: Vertex): seq[Vertex] =
  let
    (i,j,steps,stage) = v
    blocked = step(steps+1)
    startPoint = (0,-1)
    endPoint = (w-1,h)

  var vs = newSeq[Vertex]()

  if stage >= 3: return vs # already reached the end

  # wait or move
  for (dx,dy) in [(1,0),(-1,0),(0,1),(0,-1),(0,0)]:
    let
      p = (i+dx, j+dy)
      (i2,j2) = p
      validSpace = i2 >= 0 and i2 < w and j2 >= 0 and j2 < h
      occupied = validSpace and blocked[j2][i2]

    if validSpace and not occupied: vs.add((i2,j2,steps+1,stage))
    elif p == startPoint and stage == 1: vs.add((i2,j2,steps+1,stage+1))  # arrived back at start, begin last leg
    elif p == endPoint and stage != 1: vs.add((i2,j2,steps+1,stage+1))    # reached goal (either first or final time)
    elif p == (i,j) and not occupied: vs.add((i,j,steps+1,stage))  # wait

  return vs

proc bfs(start: Vertex): int =
  var
    q = initDeque[Vertex]()
    visited = initHashSet[Vertex]()
    t = 1

  q.addLast(start)

  while q.len > 0:
    let
      v = q.popFirst
      (i,j,moves,stage) = v
      isGoal = (i,j) == (w-1,h) and stage >= 2

    if isGoal: return moves
    if v in visited: continue
    visited.incl(v)

    if t mod 100000 == 0:
      let n = q.len
      echo fmt"Step {t}: queue size: {n}, visited len: {visited.len}, stage: {stage}"
    inc t

    for u in getNeighbours(v): q.addLast(u)

  high(int)

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
echo bfs(s0)

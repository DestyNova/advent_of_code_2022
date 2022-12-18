import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

type Coord = (int,int,int)
type Side = enum Left, Right, Top, Bottom, Front, Back

type Face = (Coord, Side)

let cubes = stdin.lines.toSeq.map(proc(c: string): Coord =
  let cs = c.split(",").map(parseInt)
  return (cs[0], cs[1], cs[2])
)

let cubeset = cubes.toHashSet

echo cubes

# upper bound: all sides of all cubes
let allSides = cubes.len * 6
echo fmt"allSides: {allSides}"

proc translator(x,y,z:int, s: Side): (int,int,int) -> Coord =
  case s:
    of Left:
      return proc(a,b,c: int): Coord = (x+a, y+b, z+c)
    of Bottom:
      return proc(a,b,c: int): Coord = (x-b, y+a, z+c)
    of Top:
      return proc(a,b,c: int): Coord = (x+b, y-a, z+c)
    of Front:
      return proc(a,b,c: int): Coord = (x-c, y+b, z+a)
    of Back:
      return proc(a,b,c: int): Coord = (x+c, y+b, z-a)
    of Right:
      return proc(a,b,c: int): Coord = (x-a, y+b, z-c)
    else:
      discard

proc rotator(s: Side): Side -> Side =
  case s:
    of Left:
      return proc(side: Side): Side = side
    of Bottom:
      return proc(side: Side): Side =
        case side:
          of Left: Bottom
          of Bottom: Right
          of Right: Top
          of Top: Left
          of Front: Front
          of Back: Back
    of Top:
      return proc(side: Side): Side =
        case side:
          of Left: Top
          of Bottom: Left
          of Right: Bottom
          of Top: Right
          of Front: Front
          of Back: Back
    of Front:
      return proc(side: Side): Side =
        case side:
          of Left: Front
          of Bottom: Bottom
          of Right: Back
          of Top: Top
          of Front: Right
          of Back: Left
    of Back:
      return proc(side: Side): Side =
        case side:
          of Left: Back
          of Bottom: Bottom
          of Right: Front
          of Top: Top
          of Front: Left
          of Back: Right
    of Right:
      return proc(side: Side): Side =
        case side:
          of Left: Right
          of Bottom: Bottom
          of Right: Left
          of Top: Top
          of Front: Back
          of Back: Front

proc flip(s: Side): Side =
  case s:
    of Front: Back
    of Back: Front
    else: s

proc getVertices(face: Face): HashSet[Coord] =
  let
    (c, side) = face
    (x,y,z) = c
    f = translator(x,y,z,flip(side))
  return case side:
    of Left: @[(0,0,0), (0,0,+1), (0,-1,0), (0,-1,+1)].mapIt((x+it[0],y+it[1],z+it[2])).toHashSet
    of Right: @[(1,0,0), (1,0,+1), (1,-1,0), (1,-1,+1)].mapIt((x+it[0],y+it[1],z+it[2])).toHashSet
    of Top: @[(0,0,0), (0,0,+1), (1,0,0), (1,1,+1)].mapIt((x+it[0],y+it[1],z+it[2])).toHashSet
    of Bottom: @[(0,-1,0), (0,-1,+1), (1,-1,0), (1,-1,+1)].mapIt((x+it[0],y+it[1],z+it[2])).toHashSet
    of Front: @[(0,0,0), (1,0,0), (0,-1,0), (1,-1,0)].mapIt((x+it[0],y+it[1],z+it[2])).toHashSet
    of Back: @[(0,0,1), (1,0,1), (0,-1,1), (1,-1,1)].mapIt((x+it[0],y+it[1],z+it[2])).toHashSet

proc floodSide(x: int, y: int, z: int, s: Side): HashSet[Face] =
  let c = (x,y,z)
  var reachable: HashSet[Face]
  let f = translator(x,y,z,s)
  let r = rotator(s)
  # up
  # if cube on top left
  if f(-1,+1,0) in cubes:
    # up to Bottom of cube y+1 x-1
    reachable.incl((f(-1,+1,0), r(Bottom)))
  elif f(0,+1,0) in cubes:
    # up to Left of cube y+1
    reachable.incl((f(0,+1,0), r(Left)))
  else:
    # up to Top of this cube
    reachable.incl((c, r(Top)))

  # down
  if f(-1,-1,0) in cubes:
    # down to Top of cube x-1 y-1
    reachable.incl((f(-1,-1,0), r(Top)))
  elif f(0,-1,0) in cubes:
    # down to Left of cube y-1
    reachable.incl((f(0,-1,0), r(Left)))
  else:
    # down to Bottom of this cube
    reachable.incl((c, r(Bottom)))

  # to back
  if f(-1,0,+1) in cubes:
    # back to Front of cube x-1 z+1
    reachable.incl((f(-1,0,+1), r(Front)))
  elif f(0,0,+1) in cubes:
    # back to Left of cube z+1
    reachable.incl((f(0,0,+1), r(Left)))
  else:
    # back to Back of this cube
    reachable.incl((c, r(Back)))

  # toward front
  if f(-1,0,-1) in cubes:
    # forward to Back of cube x-1 z-1
    reachable.incl((f(-1,0,-1), r(Back)))
  elif f(0,0,-1) in cubes:
    # forward to Left of cube z-1
    reachable.incl((f(0,0,-1), r(Left)))
  else:
    # back to Front of this cube
    reachable.incl((c, r(Front)))
  return reachable

# echo fmt"translator: {translator(1,2,2,Bottom)(0,1,0)}"
# echo fmt"flood fill test: {floodSide(1,2,2,Left)}"
# echo fmt"flood fill test from bottom: {floodSide(1,2,2,Bottom)}"

# flood fill from an edge cube
var
  visited: HashSet[HashSet[Coord]]
  q: seq[Face]
  count: int

let startCube = min(cubes)

q.add((startCube, Left))
echo fmt"min cube: {min(cubes)}"

# echo fmt"bottom of (1,1,1): {getVertices(((1,1,1),Bottom))}"
# echo fmt"bottom of (1,2,2): {getVertices(((1,2,2),Bottom))}"
while q.len > 0:
  let
    face = q.pop
    vertices = getVertices(face)

  if vertices in visited:
    continue # skip it, already seen
  visited.incl(vertices)

  # echo fmt"walking face: {face}"
  count += 1
  let
    (c, side) = face
    (x,y,z) = c
  echo fmt"{x} {y} {z}, {side}"
  if c notin cubes:
    raise newException(ValueError, "WAT NO CUBE?")

  # z+1 => away from us, z-1 => toward us, y+1 = up
  let reachable: HashSet[Face] = floodSide(x,y,z,side)

  # echo fmt"Reachable from {c}, {side}: {reachable}"
  # 3,2,5 Back exists, therefore 3,2,5 exists...
  if getVertices(((2,2,5), Left)) in reachable.map(getVertices):
    echo fmt"what is this: {getVertices(((2,2,5), Left))}"
    raise newException(ValueError, "WAT")
  for f in reachable:
    q.add(f)

echo fmt"Total faces walked: {count}"

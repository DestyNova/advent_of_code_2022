import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

let cubes = stdin.lines.toSeq.mapIt(it.split(",").map(parseInt))

echo cubes

# upper bound: all sides of all cubes
let allSides = cubes.len * 6
echo fmt"allSides: {allSides}"

# count intersecting faces
# explode each plane
type Coord = (int,int,int)
var
  faces: HashSet[HashSet[Coord]]
  allFaces: seq[HashSet[Coord]]
  dupes: int

for cube in cubes:
  let (x,y,z) = (cube[0], cube[1], cube[2])
  echo fmt"cube: {x}, {y}, {z}"
  let
    top = @[(x,y,z),(x+1,y,z+1)].toHashSet
    front = @[(x,y,z),(x+1,y+1,z)].toHashSet
    back = @[(x,y,z+1),(x+1,y+1,z+1)].toHashSet
    left = @[(x,y,z+1),(x,y+1,z)].toHashSet
    right = @[(x+1,y,z+1),(x+1,y+1,z)].toHashSet
    bottom = @[(x,y+1,z),(x+1,y+1,z+1)].toHashSet

  if top in faces: dupes += 1
  if front in faces: dupes += 1
  if back in faces: dupes += 1
  if left in faces: dupes += 1
  if right in faces: dupes += 1
  if bottom in faces: dupes += 1

  faces.incl(top)  # top
  faces.incl(front)  # front
  faces.incl(back)  # back
  faces.incl(left)  # left
  faces.incl(right)  # right
  faces.incl(bottom)  # bottom
  # echo fmt"faces after {cube}: {faces}"

  allFaces.add(top)  # top
  allFaces.add(front)  # front
  allFaces.add(back)  # back
  allFaces.add(left)  # left
  allFaces.add(right)  # right
  allFaces.add(bottom)  # bottom

echo faces.len
echo allFaces.len
echo faces.len - dupes

import std/[strformat, strutils, sugar, tables]

let
  input = stdin.readAll.split("\n\n")
  g = input[0].splitLines
  h = g.len
  dirs = input[1].strip

type
  Coord = (int,int)
  MoveKind = enum mTurn, mMove
  Turn = enum L, R
  Move = ref object
    case kind: MoveKind
      of mTurn: dir: Turn
      of mMove: steps: int

proc `$`(move: Move): string =
  case move.kind
    of mTurn: fmt"turn {move.dir}"
    of mMove: fmt"fw {move.steps}"

var
  m: Table[Coord, bool]
  w: int


for j in 0..h-1:
  for i in 0..g[j].len-1:
    if i > w: w = i
    case g[j][i]:
      of '#': m[(i+1,j+1)] = true
      of '.': m[(i+1,j+1)] = false
      else: continue

# parse dirs

let moves: seq[Move] = collect:
  for (token, isSep) in dirs.tokenize({'L','R'}):
    if isSep:
      Move(kind: mTurn, dir: (if token == "L": L else: R))
    else:
      Move(kind: mMove, steps: token.parseInt)

# procs
proc turn(facing: int, dir: Turn): int =
  if dir == L: (facing + 3) mod 4 else: (facing + 1) mod 4

# find start point
var start: Coord

for i in 1..w:
  if (i,1) in m:
    start = (i,1)
    break

# begin walking...
var
  pos = start
  facing = 0

for move in moves:
  case move.kind:
    of mTurn:
      facing = turn(facing, move.dir)
    of mMove:
      # 128350 is too low
      let (x,y) = case facing:
        of 0: (1,0)
        of 1: (0,1)
        of 2: (-1,0)
        else: (0,-1)

      for s in 1..move.steps:
        let dest = (pos[0] + x, pos[1] + y)
        # hit a wall, stop
        if dest in m and m[dest]:
          break
        # empty
        elif dest in m:
          pos = dest
        # wrapping
        elif dest notin m:
          var pos2 = pos
          while true:
            let dest2 = (pos2[0] - x, pos2[1] - y)
            if dest2 notin m:
              # ONLY move if there's no wall at the destination
              if not m[pos2]:
                pos = pos2
              break
            pos2 = dest2

echo fmt"final pos: {pos}, facing: {facing}"
echo fmt"password: {4 * pos[0] + 1000 * pos[1] + facing}"

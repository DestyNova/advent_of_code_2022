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
  Dir = enum E,S,W,N
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
    if i >= w: w = i + 1
    case g[j][i]:
      of '#': m[(i+1,j+1)] = true
      of '.': m[(i+1,j+1)] = false
      else: continue

let
  faceL = w div 3

# parse dirs

let moves: seq[Move] = collect:
  for (token, isSep) in dirs.tokenize({'L','R'}):
    if isSep:
      Move(kind: mTurn, dir: (if token == "L": L else: R))
    else:
      Move(kind: mMove, steps: token.parseInt)

# procs
proc turn(facing: Dir, turn: Turn): Dir =
  Dir(if turn == L: (facing.ord + 3) mod 4 else: (facing.ord + 1) mod 4)

# find start point
var start: Coord

for i in 1..w:
  if (i,1) in m:
    start = (i,1)
    break

echo fmt"start: {start}"

# begin walking...
var
  pos = start
  facing = E

proc getRegion(pos: Coord): int =
  let
    xChunk = (pos[0]-1) div faceL
    yChunk = (pos[1]-1) div faceL

  return {(1,0): 1, (2,0): 2, (1,1): 3, (0,2): 4, (1,2): 5, (0,3): 6}.toTable[(xChunk,yChunk)]

proc translate(c: Coord, xSides, ySides: int): Coord = (c[0] + faceL * xSides, c[1] + faceL * ySides)
proc rotate(c: Coord, times: int): Coord =
  if times == 0:
    c
  else:
    let
      offX = (c[0]-1) mod faceL
      offY = (c[1]-1) mod faceL
      c2 = if offX == 0: (c[0] - offX + faceL - offY - 1, c[1] - offY)
           elif offX == faceL-1: (c[0] - offX + faceL - offY - 1, c[1] - offY + faceL - 1)
           elif offY == 0: (c[0] - offX + faceL - 1, c[1] - offY + offX)
           elif offY == faceL-1: (c[0] - offX, c[1] - offY + offX)
           else: raise newException(ValueError, fmt"must rotate on edge, but actually at {c}")

    rotate(c2, times - 1)

proc getForwardOffset(orientation: Dir): Coord =
  case orientation:
    of E: (1,0)
    of S: (0,1)
    of W: (-1,0)
    of N: (0,-1)

for move in moves:
  case move.kind:
    of mTurn:
      facing = turn(facing, move.dir)
    of mMove:
      for s in 1..move.steps:
        let
          (x,y) = getForwardOffset(facing)
          dest = (pos[0] + x, pos[1] + y)
        # hit a wall, stop
        if dest in m and m[dest]:
          break
        # empty
        elif dest in m:
          pos = dest
        # wrapping
        elif dest notin m:
          let region = getRegion(pos)
          let (facing2, translation) = case region:
            of 1:
              case facing:
                of W: (E, translate(rotate(pos, 2), -2, 2))
                of N: (E, translate(rotate(pos, 1), -2, 3))
                else: raise newException(ValueError, fmt"bad! facing: {facing}")
            of 2:
              case facing:
                of N: (N, translate(pos, -2, 4))
                of E: (W, translate(rotate(pos, 2), 0, 2))
                of S: (W, translate(rotate(pos, 1), 0, 1))
                else: raise newException(ValueError, fmt"bad! facing: {facing}")
            of 3:
              case facing:
                of W: (S, translate(rotate(pos, 3), -1, 0))
                of E: (N, translate(rotate(pos, 3), 1, 0))
                else: raise newException(ValueError, fmt"bad! facing: {facing}")
            of 4:
              case facing:
                of N: (E, translate(rotate(pos, 1), 0, -1))
                of W: (E, translate(rotate(pos, 2), 0, -2))
                else: raise newException(ValueError, fmt"bad! facing: {facing}")
            of 5:
              case facing:
                of E: (W, translate(rotate(pos, 2), 2, -2))
                of S: (W, translate(rotate(pos, 1), 0, 1))
                else: raise newException(ValueError, fmt"bad! facing: {facing}")

            of 6:
              case facing:
                of E: (N, translate(rotate(pos, 3), 1, 0))
                of S: (S, translate(pos, 2, -4))
                of W: (S, translate(rotate(pos, 3), 1, -4))
                else: raise newException(ValueError, fmt"bad! facing: {facing}")
            else: raise newException(ValueError, fmt"bad region: {region}")
          let
            (dx,dy) = getForwardOffset(facing2)
            (x1,y1) = translation
            dest2 = (x1+dx, y1+dy)

          # ONLY move if there's no wall at the destination
          if not m[dest2]:
            pos = dest2
            facing = facing2

echo fmt"final pos: {pos}, facing: {facing}"
echo fmt"w: {w}, h: {h}"
echo fmt"password: {4 * pos[0] + 1000 * pos[1] + facing.ord}"

import std/[sequtils, strformat, strutils, deques, intsets]

type Vertex = (int,int)

let
  g = stdin.lines.toSeq
  w = g[0].len
  h = g.len

proc getHeight(c: char): int =
  case c:
    of 'S': ord('a')
    of 'E': ord('z')
    else: ord(c)

proc getNeighbours(v: Vertex): seq[Vertex] =
  var vs = newSeq[Vertex]()

  for j in @[-1,0,1]:
    for i in @[-1,0,1]:
      let
        x = v[0]+i
        y = v[1]+j

      if x >= 0 and x < w and y >= 0 and y < h and abs(i)+abs(j) == 1:
        vs.add((x,y))

  return vs

proc getIndex(v: Vertex): int = v[0] + v[1]*w
proc getVertex(index: int): Vertex = (index mod w, index div w)

proc bfs(sources: seq[Vertex]): int =
  var
    q = sources.mapIt((it.getIndex,0)).toDeque
    visited = sources.mapIt(it.getIndex).toIntSet

  while q.len > 0:
    let
      (u,steps) = q.popFirst
      (i,j) = getVertex(u)
      h1 = getHeight(g[j][i])

    for (i2,j2) in getNeighbours((i,j)):
      let v = getIndex((i2,j2))

      if not (v in visited):
        let h2 = getHeight(g[j2][i2])

        if h2 <= h1 + 1:
          visited.incl(v)
          # if we can reach it and it's an end node, we've found the minimum steps
          if g[j2][i2] == 'E': return steps + 1
          q.addLast((v, steps + 1))

  raise newException(ValueError, "Couldn't find destination vertex")

var sources = newSeq[Vertex]()

for j in 0..h-1:
  for i in 0..w-1:
    if g[j][i] == 'a' or g[j][i] == 'S':
      sources.add((i,j))

let d = bfs(sources)
echo fmt"shortest distance: {d}"

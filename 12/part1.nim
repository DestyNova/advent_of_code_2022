import std/[sequtils, strformat, heapqueue]

type Vertex = (int,int)

const Inf = high(int)

let
  g = stdin.lines.toSeq
  w = g[0].len
  h = g.len
  numVertices = (w*h)-1

proc find(c: char): Vertex =
  for j in 0..h-1:
    for i in 0..w-1:
      if g[j][i] == c: return (i,j)

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

let
  source = find('S')
  dest = find('E')

type PrioVert = (int, int)
proc `<`(a, b: PrioVert): bool = a[0] < b[0]

proc djikstra(s: Vertex): seq[int] =
  var
    dist = newSeq[int](w*h)
    prev = newSeq[int](w*h)
    q = initHeapQueue[PrioVert]()
    sIndex = getIndex(s)

  dist[sIndex] = 0

  for v in 0..numVertices:
    if v != sIndex:
      dist[v] = Inf
      prev[v] = -1

    q.push((v, dist[v]))

  while q.len > 0:
    let
      (u,uDist) = q.pop
      (i,j) = getVertex(u)
      h1 = getHeight(g[j][i])

    for (i2,j2) in getNeighbours(u.getVertex):
      let h2 = getHeight(g[j2][i2])

      if h2 <= h1 + 1 and dist[u] < high(int):
        let
          alt = dist[u] + 1
          v = getIndex((i2,j2))
        if alt < dist[v]:
          dist[v] = alt
          prev[v] = u
          q.push((v, alt))

  dist

let d = djikstra(source)
echo fmt"dist: {d[getIndex(dest)]}"

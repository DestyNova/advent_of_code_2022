import std/[sequtils, strformat]

type Vertex = (int,int)

const Inf = high(int)

let
  g = stdin.lines.toSeq
  w = g[0].len
  h = g.len
  numVertices = (w*h)-1

echo g

proc find(c: char): Vertex =
  for j in 0..h-1:
    for i in 0..w-1:
      if g[j][i] == c: return (i,j)

proc getHeight(c: char): int =
  case c:
    of 'S': ord('a')
    of 'E': ord('z')
    else: ord(c)

proc getIndex(v: Vertex): int = v[0] + v[1]*w
proc getVertex(index: int): Vertex = (index mod w, index div w)

let
  source = find('S')
  dest = find('E')

echo fmt"source: {source}, dest: {dest}"

var
  dist = newSeq[seq[int]](w*h)
  next = newSeq[seq[int]](w*h)

echo "Computing edge distances"

# init inner arrays
for u in 0..numVertices:
  dist[u] = newSeq[int](w*h)
  next[u] = newSeq[int](w*h)

# compute edge distances
for u in 0..numVertices:
  let
    (i,j) = getVertex(u)
    h1 = getHeight(g[j][i])

  # echo $(i,j)
  # oh man
  for v in 0..numVertices:
    let (i2,j2) = getVertex(v)

    # non-adjacent
    if abs(i2-i) > 1 or abs(j2-j) > 1 or (i2-i == j2-j):
      dist[u][v] = high(int)
      next[u][v] = v
      continue

    # distance to self
    if u == v:
      dist[u][v] = 0
      next[u][v] = v
      continue

    let h2 = getHeight(g[j2][i2])
    next[u][v] = v
    if h2 > h1 + 1:
      # too high, don't try
      dist[u][v] = Inf
    else:
      dist[u][v] = 1

echo "Edge distances computed"
# echo dist

# Floyd-Warshall
for k in 0..numVertices:
  echo fmt"{k}/{numVertices}"
  for i in 0..numVertices:
    for j in 0..numVertices:
      let
        a = dist[i][k]
        b = dist[k][j]
        altDistance = if max(a,b) < high(int): a + b else: max(a,b)
      if dist[i][j] > altDistance:
        dist[i][j] = altDistance
        next[i][j] = next[i][k]

echo "Paths computed"

proc path(a, b: Vertex): seq[Vertex] =
  var
    u = getIndex(a)
    v = getIndex(b)
    p = @[a]

  while u != v:
    echo fmt"u: {a} = {u}, v: {b} = {v}, p: {p}"
    u = next[u][v]
    echo fmt"next: {u}"
    p.add(getVertex(u))
  return p

# echo fmt"w: {w}, h: {h}, source: {source}, sourceIndex: {u}"
# echo fmt"w: {w}, h: {h}, dest: {dest}, destIndex: {v}"

let p = path(source, dest)

# works for the sample, produces too low result for full input
echo fmt"dist: {dist[getIndex(source)][getIndex(dest)]}"

echo p
for j in 0..h:
  for i in 0..w:
    let u: Vertex = (i,j)
    if u in p:
      stdout.write("x")
    else:
      stdout.write(".")
  echo ""

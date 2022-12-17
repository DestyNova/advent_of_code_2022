import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# vertex needs to encode valve label, pressure released, mins remaining and table of turned??
type Vertex = (string,int,int,HashSet[string],seq[string])
const Inf = high(int)

var valves: Table[string, (int, seq[string])]

proc getNeighbours(v: Vertex): seq[Vertex] =
  let (label, released, mins, unturned, moves) = v
  var vs = newSeq[Vertex]()
  let (flowRate, ns) = valves[v[0]]

  # add "turn this valve" vertex if possible
  if label in unturned:
    vs.add((v[0], (mins-1)*flowRate + released, mins - 1, unturned.difference([label].toHashSet),moves & @[fmt"T {label}"]))

  # add reachable paths
  if mins > 1:
    for n in ns:
      vs.add((n, released, mins - 1, unturned, moves & @[fmt"> {n}"]))

  return vs

# greedy approximation...
proc `<`(a, b: Vertex): bool = a[1] > b[1]

proc getApproximateOptimum(unturned: HashSet[string], mins: int): int =
  let rates = unturned.mapIt(valves[it][0]).sortedByIt(-it)
  var
    acc = 0
    i = mins - 1
  for r in rates:
    acc += r * i
    i -= 2
    if i < 1: break
  acc

proc bfs(start: Vertex): (int, seq[string]) =
  var
    maxReleased = -Inf
    bestMoves: seq[string] = @[]
    q = initHeapQueue[Vertex]()

  q.push(start)

  while q.len > 0:
    let
      v = q.pop
      (label, released, mins, unturned, moves) = v
      bestPossible = released + getApproximateOptimum(unturned, mins)

    if released > maxReleased:
      maxReleased = released
      bestMoves = moves
      echo fmt"new best v: {v}, maxReleased: {maxReleased}, bestPossible: {bestPossible}"

    # echo fmt"inspecting vertex: {v}"
    if bestPossible > maxReleased:
      for u in getNeighbours(v):
        let
          (_, uReleased, _, _, uMoves) = u
        # echo fmt"u: {u}"
        if uReleased > maxReleased:
          maxReleased = uReleased
          bestMoves = uMoves
          echo fmt"new best neighbour u: {u}, maxReleased: {maxReleased}"
        q.push(u)

  (maxReleased, bestMoves)

for line in stdin.lines:
  var
    valve: string
    flowRate: int
    destinations: string

  if not scanf(line, "Valve $w has flow rate=$i; tunnel leads to valve $+", valve, flowRate, destinations):
    # why
    discard scanf(line, "Valve $w has flow rate=$i; tunnels lead to valves $+", valve, flowRate, destinations)
  echo fmt"valve: {valve}, flowRate: {flowRate}, destinations: {destinations}"

  valves[valve] = (flowRate, destinations.split(", "))

echo valves
let
  moves: seq[string] = @[]
  start: Vertex = ("AA",0,30,valves.keys.toSeq.toHashSet,moves)
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(valves.keys.toSeq.toHashSet, 30)}"
echo fmt"starting unturned: {valves.keys.toSeq.toHashSet}"
echo bfs(start)

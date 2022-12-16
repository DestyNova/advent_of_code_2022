import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# cost of moving = 1
# cost of turning valve V (iff V off) = 1 - T*Flow[V]
# negative costs: do bfs?

# vertex needs to encode my valve label, elephant's valve, pressure released, mins remaining and table of unturned??
# type Vertex = (string,string,int,int,HashSet[string],seq[string])
type Vertex = (int,int,int,int,HashSet[int])
const Inf = high(int)

var valveNames: Table[string, (int, seq[string], int)]
var valves: Table[int, (int, seq[int])]

proc getNeighbours(v: Vertex): seq[Vertex] =
  let
    # (myV, elephantV, released, mins, unturned, moves) = v
    (myV, elephantV, released, mins, unturned) = v
    (flowRate1, ns1) = valves[myV]
    (flowRate2, ns2) = valves[elephantV]
    m = mins - 1

  if m < 1: return

  var vs = newSeq[Vertex]()

  # we both turn a valve, but it must be two different valves
  if myV in unturned and elephantV in unturned and myV != elephantV:
    # vs.add((myV, elephantV, m*flowRate1 + m*flowRate2 + released, m, unturned.difference([myV, elephantV].toHashSet),moves & @[fmt"T {myV}, T {elephantV}"]))
    vs.add((myV, elephantV, m*flowRate1 + m*flowRate2 + released, m, unturned.difference([myV, elephantV].toHashSet)))

  # otherwise, at least one of us moves
  # add my reachable paths
  for n in ns1:
    # I move to valve n and elephant turns this valve
    if elephantV in unturned:
      vs.add((n, elephantV, m*flowRate2 + released, m, unturned.difference([elephantV].toHashSet)))
    # or we both move to another valve, but only if there's enough time
    if m > 1:
      for n2 in ns2:
        # vs.add((n, n2, released, m, unturned, moves & @[fmt"> {n}, > {n2}"]))
        vs.add((n, n2, released, m, unturned))
  # I turn this valve and elephant moves to valve n2
  for n2 in ns2:
    if myV in unturned:
      # vs.add((myV, n2, m*flowRate1 + released, m, unturned.difference([myV].toHashSet),moves & @[fmt"T {myV}, > {n2}"]))
      vs.add((myV, n2, m*flowRate1 + released, m, unturned.difference([myV].toHashSet)))

  return vs

proc getApproximateOptimum(unturned: HashSet[int], mins: int): int =
  let rates = unturned.mapIt(valves[it][0]).sortedByIt(-it)
  var
    acc = 0
    m = mins - 1
    i = 0
    n = len(rates)
  while i < n - 1 and m > 0:
    acc += rates[i]*m + rates[i+1]*m
    m -= 2
    i += 2
  acc

# greedy approximation...
proc `<`(a, b: Vertex): bool =
  # let
  #   aPossible = a[2] + getApproximateOptimum(a[4], a[3])
  #   bPossible = b[2] + getApproximateOptimum(b[4], b[3])
  a[2] > b[2]

proc bfs(start: Vertex): (int, seq[string]) =
  var
    maxReleased = -Inf
    bestMoves: seq[string] = @[]
    q = initHeapQueue[Vertex]()
    step = 0

  q.push(start)

  while q.len > 0:
    if step mod 1000000 == 0:
      let n = q.len
      echo fmt"Step {step}: queue size: {n}, maxReleased: {maxReleased}"
      if n > 30000:
        for i in 1..25000:
          let
            a = q[n-i]
            aPossible = a[2] + getApproximateOptimum(a[4], a[3])

          if aPossible <= maxReleased:
            q.del(n-i)
          else:
            break
    inc step
    let
      v = q.pop
      # (myV, elephantV, released, mins, unturned, moves) = v
      (myV, elephantV, released, mins, unturned) = v
      bestPossible = released + getApproximateOptimum(unturned, mins)

    if released > maxReleased:
      maxReleased = released
      # bestMoves = moves
      echo fmt"new best v: {v}, maxReleased: {maxReleased}, bestPossible: {bestPossible}"

    if bestPossible > maxReleased:
      for u in getNeighbours(v):
        let
          # (_, _, uReleased, _, _, uMoves) = u
          (_, _, uReleased, _, _) = u
        # echo fmt"u: {u}"
        if uReleased > maxReleased:
          maxReleased = uReleased
          # bestMoves = uMoves
          echo fmt"new best neighbour u: {u}, maxReleased: {maxReleased}, bestPossible estimate was: {bestPossible}"
        q.push(u)

  (maxReleased, bestMoves)

var i = 0
for line in stdin.lines:
  var
    valve: string
    flowRate: int
    destinations: string

  if not scanf(line, "Valve $w has flow rate=$i; tunnel leads to valve $+", valve, flowRate, destinations):
    # why
    discard scanf(line, "Valve $w has flow rate=$i; tunnels lead to valves $+", valve, flowRate, destinations)
  echo fmt"valve: {valve}, flowRate: {flowRate}, destinations: {destinations}"

  valveNames[valve] = (flowRate, destinations.split(", "), i)
  i += 1

for k,v in valveNames:
  let (flowRate, dests, i) = v
  valves[i] = (flowRate, dests.mapIt(valveNames[it][2]))

echo valves

let
  moves: seq[string] = @[]
  # start: Vertex = ("AA","AA",0,26,valves.keys.toSeq.toHashSet,moves)
  startValve = valveNames["AA"][2]
  start: Vertex = (startValve,startValve,0,26,valves.keys.toSeq.toHashSet)
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(valves.keys.toSeq.toHashSet, 30)}"
echo fmt"starting unturned: {valves.keys.toSeq.toHashSet}"
echo bfs(start)

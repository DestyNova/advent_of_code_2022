import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# vertex needs to encode my valve label, elephant's valve, pressure released, mins remaining and list of unturned
type Vertex = (int8,int8,int,int,int)
const Inf = high(int)

var valveNames: Table[string, (int, seq[string], int8)]
var valves: Table[int8, (int, seq[int8])]
var useless: int

proc encodeValves(keys: seq[int8]): int =
  var x = 0
  for i in keys: x = x or (1 shl i)
  x

proc holds(x: int, key: int8): bool = (x and (1 shl key)) != 0
proc without(x: int, keys: seq[int8]): int =
  var y = x
  for k in keys:
    y = y xor (1 shl k)
  y

proc getNeighbours(v: Vertex): seq[Vertex] =
  let
    (myV, elephantV, released, mins, unturned) = v
    (flowRate1, ns1) = valves[myV]
    (flowRate2, ns2) = valves[elephantV]
    m = mins - 1

  if m < 1: return

  var vs = newSeq[Vertex]()

  # we both turn a valve, but it must be two different valves, and neither can be useless...
  if unturned.holds(myV) and unturned.holds(elephantV) and myV != elephantV and (valves[myV][0] > 0 and valves[elephantV][0] > 0):
    vs.add((myV, elephantV, m*flowRate1 + m*flowRate2 + released, m, unturned.without(@[myV, elephantV])))

  # otherwise, at least one of us moves
  # add my reachable paths
  for n in ns1:
    # I move to valve n and elephant turns this valve
    if unturned.holds(elephantV) and valves[elephantV][0] > 0:
      vs.add((n, elephantV, m*flowRate2 + released, m, unturned.without(@[elephantV])))
    # or we both move to another valve, but only if there's enough time
    elif m > 1:
      for n2 in ns2:
        # vs.add((n, n2, released, m, unturned, moves & @[fmt"> {n}, > {n2}"]))
        vs.add((n, n2, released, m, unturned))
  # I turn this valve and elephant moves to valve n2
  for n2 in ns2:
    if unturned.holds(myV) and valves[myV][0] > 0:
      vs.add((myV, n2, m*flowRate1 + released, m, unturned.without(@[myV])))

  return vs

proc getApproximateOptimum(unturned: int, mins: int): int =
  let rates = collect(
    for k in 0..63:
      if unturned.holds(int8(k)):
        valves[int8(k)][0]
    ).sortedByIt(-it)
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

proc `<`(a, b: Vertex): bool =
  # a[2] >= b[2]
  let
    aPossible = 1*a[2] + 1*getApproximateOptimum(a[4], a[3])
    bPossible = 1*b[2] + 1*getApproximateOptimum(b[4], b[3])
  aPossible >= bPossible

proc bfs(start: Vertex): (int, seq[string]) =
  var
    maxReleased = -Inf
    bestMoves: seq[string] = @[]
    q = initHeapQueue[Vertex]()
    visited = initHashSet[Vertex]()
    step = 0

  q.push(start)

  while q.len > 0:
    if step mod 100000 == 0:
      let n = q.len
      echo fmt"Step {step}: queue size: {n}, maxReleased: {maxReleased}, visited len: {visited.len}"
    inc step
    let
      v = q.pop
      (myV, elephantV, released, mins, unturned) = v
      bestPossible = released + getApproximateOptimum(unturned, mins)

    if released > maxReleased:
      maxReleased = released
      # bestMoves = moves
      echo fmt"new best v: {v}, maxReleased: {maxReleased}, bestPossible: {bestPossible}"

    if bestPossible > maxReleased and useless != unturned:
      for u in getNeighbours(v):
        let
          # (_, _, uReleased, _, _, uMoves) = u
          (_, _, uReleased, _, _) = u
        # echo fmt"u: {u}"
        if uReleased > maxReleased:
          maxReleased = uReleased
          # bestMoves = uMoves
          echo fmt"new best neighbour u: {u}, maxReleased: {maxReleased}, bestPossible estimate was: {bestPossible}"
        if u notin visited:
          q.push(u)
          visited.incl(u)

  (maxReleased, bestMoves)

var i: int8 = 0
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
  # add to useless set
  if flowRate == 0: useless = useless or (1 shl i)
  i += 1

for k,v in valveNames:
  let (flowRate, dests, i) = v
  valves[i] = (flowRate, dests.mapIt(valveNames[it][2]))

echo valves

let
  # start: Vertex = ("AA","AA",0,26,valves.keys.toSeq.toHashSet,moves)
  startValve = valveNames["AA"][2]
  start: Vertex = (startValve,startValve,0,26,encodeValves(valves.keys.toSeq))
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(encodeValves(valves.keys.toSeq), 30)}"
echo fmt"starting unturned: {valves.keys.toSeq}"
echo fmt"useless valves: {useless}"
echo bfs(start)
echo fmt"Initial state: {valves.keys.toSeq} => {encodeValves(valves.keys.toSeq):#b}"

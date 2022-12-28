import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# state needs to encode my valve label, elephant's valve, pressure released, mins remaining and list of unturned
type
  State = (int8,int8,int,int,int)
  Vertex = object
    s: State
    f: int
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

proc getNeighbours(v: State): seq[State] =
  let
    (myV, elephantV, released, mins, unturned) = v
    (flowRate1, ns1) = valves[myV]
    (flowRate2, ns2) = valves[elephantV]
    m = mins - 1

  if m < 1: return

  var vs = newSeq[State]()

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

proc getApproximateOptimum(s: State): int =
  let
    mins = s[3]
    unturned = s[4]
    rates = collect(
    for k in 0..63:
      if unturned.holds(int8(k)):
        valves[int8(k)][0]
    ).sortedByIt(-it)
  # let rates = unturned.mapIt(valves[it][0]).sortedByIt(-it)
  # echo fmt"rates: {rates}"
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
proc `<`(a, b: Vertex): bool = a.f > b.f

# highest result so far... 2082... 2297, 2543, 2615
proc search(start: State): int =
  var
    maxReleased = -Inf
    visited = initTable[State,int]()
    q = initHeapQueue[Vertex]()
    step = 0

  q.push(Vertex(s: start, f: getApproximateOptimum(start)))

  while q.len > 0:
    if step mod 1000 == 0:
      let n = q.len
      echo fmt"Step {step}: queue size: {n}, maxReleased: {maxReleased}"
      echo fmt"Visited len: {visited.len}"
    inc step
    let
      v = q.pop
      (_, _, released, _, unturned) = v.s
      bestPossible = v.f

    if released > maxReleased:
      maxReleased = released
      echo fmt"new best v: {v}, maxReleased: {maxReleased}, bestPossible: {bestPossible}"
    # else:
    #   echo fmt"Popped v: {v}, maxReleased: {maxReleased}"

    if bestPossible > maxReleased and useless != unturned:
      var
        discarded = false
        bestDiscarded = low(int)

      for u in getNeighbours(v.s):
        let
          (_, _, uReleased, _, _) = u
          uF = uReleased + getApproximateOptimum(u)
          v2 = Vertex(s: u, f: uF)
          inClosed = u in visited
          # inOpen = q.find(v2) == -1
        # echo fmt"u: {u}"
        if uReleased > maxReleased:
          maxReleased = uReleased
          # echo fmt"new best neighbour u: {u}, maxReleased: {maxReleased}, bestPossible estimate was: {bestPossible}"
        # if not inClosed and not inOpen:
        #   # echo "Not in closed or open"
        #   q.push(Vertex(s:u, f:uF))
        elif inClosed and visited[u] < uF:
          # echo "Found updatable successor in visited set"
          visited.del(u)
          q.push(v2)
        elif not inClosed and uF >= v.f:
          # should this not be f: state.released + getApproximateOptimum(state)? i.e. g(state)?
          # yes... updated getApproximateOptimum
          # echo fmt"Pushing child {u} with f: {uF}"
          # if inOpen: q.push(v2)
          if q.find(v2) == -1: q.push(v2)
        elif not inClosed:
          # echo fmt"Not pushing {u} with f: {uF} not better than {v.f}"
          discarded = true
          bestDiscarded = max(bestDiscarded, uF)

      if discarded:
        let v2 = Vertex(s: v.s, f: bestDiscarded)
        # echo fmt"Pushing updated {v2}"
        q.push(v2)
      else:
        visited[v.s] = v.f

  maxReleased

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
  if flowRate == 0:
    echo fmt"crappy valve: {i}"
    useless = useless or (1 shl i)
  i += 1

for k,v in valveNames:
  let (flowRate, dests, i) = v
  valves[i] = (flowRate, dests.mapIt(valveNames[it][2]))

echo valves

let
  # start: State = ("AA","AA",0,26,valves.keys.toSeq.toHashSet,moves)
  startValve = valveNames["AA"][2]
  start = (startValve,startValve,0,26,encodeValves(valves.keys.toSeq))
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(start)}"
echo fmt"starting unturned: {valves.keys.toSeq}"
echo fmt"useless valves: {useless}"
echo search(start)
echo fmt"Initial state: {valves.keys.toSeq} => {encodeValves(valves.keys.toSeq):#b}"

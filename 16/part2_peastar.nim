import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# state needs to encode whether it's player 1 or 2's turn, current valve, pressure released, mins remaining and unturned valves
type State = (bool,int8,int,int8,int)
type Vertex = object
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
proc without(x: int, key: int8): int = x xor (1 shl key)

proc getNeighbours(v: State): seq[State] =
  let
    (p1, valve, released, mins, unturned) = v
    (flowRate, ns) = valves[valve]
    m = mins - 1

  var
    vs = newSeq[State]()
    noActions = true

  # turn a valve
  if m >= 2 and unturned.holds(valve) and flowRate > 0:
    vs.add((p1, valve, m*flowRate + released, m, unturned.without(valve)))
    noActions = false
  # move
  if m >= 3:
    for n in ns:
      vs.add((p1, n, released, m, unturned))
    noActions = false

  if noActions and p1:
    let
      startValve = valveNames["AA"][2]
      p2Start: State = (false,startValve,released,int8(26),unturned)
    vs.add(p2Start)

  return vs

proc getApproximateOptimum(s: State): int =
  let
    (p1, _, released, mins, unturned) = s
    rates = collect(
      for k in 0..63:
        if unturned.holds(int8(k)):
          (k,valves[int8(k)][0])
      ).sortedByIt(-it[1])

  var
    acc = 0
    m = mins - 1
    eM = 25
    i = 0
    playerOffset = if p1: 26-m else: 0
    n = len(rates)
  while i < n and (m > 0 or eM > 0):
    if p1:
      # elephant probably has more minutes
      acc += rates[i][1]*eM
    if m > 0 and i + playerOffset < n:
      acc += rates[i+playerOffset][1]*m
    m -= 2
    eM -= 2
    i += 1
  released + acc

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
    if step mod 1000000 == 0:
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
          state = u
          (_, _, uReleased, _, _) = state
          uF = getApproximateOptimum(state)
          inClosed = state in visited
        # echo fmt"u: {u}"
        if uReleased > maxReleased:
          maxReleased = uReleased
          # echo fmt"new best neighbour u: {u}, maxReleased: {maxReleased}, bestPossible estimate was: {bestPossible}"
        if inClosed and visited[state] < uF:
          # echo "Found updatable successor in visited set"
          visited.del(state)
        elif not inClosed and uF >= v.f:
          # should this not be f: state.released + getApproximateOptimum(state)? i.e. g(state)?
          # yes... updated getApproximateOptimum
          # echo fmt"Pushing child {state} with f: {uF}"
          q.push(Vertex(s: state, f: uF))
        elif not inClosed:
          # echo fmt"Not pushing {state} with f: {uF} not better than {v.f}"
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
  start: State = (true,startValve,0,int8(26),encodeValves(valves.keys.toSeq))
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(start)}"
echo fmt"starting unturned: {valves.keys.toSeq}"
echo fmt"useless valves: {useless}"
echo search(start)
echo fmt"Initial state: {valves.keys.toSeq} => {encodeValves(valves.keys.toSeq):#b}"

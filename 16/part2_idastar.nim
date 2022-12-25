import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# vertex needs to encode whether it's player 1 or 2's turn, current valve, pressure released, mins remaining and unturned valves
type Vertex = (bool,int8,int,int8,int)
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

proc getNeighbours(v: Vertex): seq[Vertex] =
  let
    (p1, valve, released, mins, unturned) = v
    (flowRate, ns) = valves[valve]
    m = mins - 1

  var
    vs = newSeq[Vertex]()
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
      p2Start: Vertex = (false,startValve,released,int8(26),unturned)
    vs.add(p2Start)

  return vs

proc getApproximateOptimum(p1: bool, unturned: int, mins: int): int =
  let rates = collect(
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
  acc

# greedy approximation...
proc `<`(a, b: Vertex): bool =
  let
    (aP1, _, aReleased, aMins, aUnturned) = a
    (bP1, _, bReleased, bMins, bUnturned) = b
    aPossible = aReleased + getApproximateOptimum(aP1, aUnturned, aMins)
    bPossible = bReleased + getApproximateOptimum(bP1, bUnturned, bMins)
  aPossible > bPossible

proc dfs(v: Vertex, limit: int): int =
  let
    (p1, _, released, mins, unturned) = v
    f = released + getApproximateOptimum(p1, unturned, mins)
    isGoal = mins <= 1 and not p1

  # echo fmt"dfs: {v}, f: {f}, isGoal: {isGoal}, limit: {limit}"
  if isGoal: return -released
  if f < limit: return f

  var maxReleased = low(int)
  if released > maxReleased:
    maxReleased = released
    # echo fmt"new best v: {v}, maxReleased: {maxReleased}"
  # echo fmt"{v} has these neighbours: {getNeighbours(v)}"
  for u in getNeighbours(v):
    # echo fmt"dfs, recursing into {u}"
    let uF = dfs(u, limit)
    if uF < 0: return uF  # reached goal
    elif uF > maxReleased: maxReleased = uF

  # echo fmt"dfs: {v}, returning {maxReleased}"
  maxReleased

# IDA*
proc search(start: Vertex): int =
  for i in 0..100:
    let r = dfs(start, 1708 - i)
    echo fmt"IDA* round {i}, max f: {r}"
    if r < 0:
      echo "Goal state reached"
      return -r

  raise newException(ValueError, "Couldn't find solution within desired bounds.")

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
  # start: Vertex = ("AA","AA",0,26,valves.keys.toSeq.toHashSet,moves)
  startValve = valveNames["AA"][2]
  start: Vertex = (true,startValve,0,int8(26),encodeValves(valves.keys.toSeq))
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(true,encodeValves(valves.keys.toSeq), 26)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(false,encodeValves(valves.keys.toSeq), 26)}"
echo fmt"starting unturned: {valves.keys.toSeq}"
echo fmt"useless valves: {useless}"
echo search(start)
echo fmt"Initial state: {valves.keys.toSeq} => {encodeValves(valves.keys.toSeq):#b}"

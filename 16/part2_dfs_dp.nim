import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# vertex needs to encode whether it's player 1 or 2's turn, current valve, pressure released, mins remaining and unturned valves
type Vertex = (bool,int8,int,int8,int)

var valveNames: Table[string, (int, seq[string], int8)]
var valves: Table[int8, (int, seq[int8])]
var useless: set[int8]

proc encodeValves(keys: seq[int8]): int =
  var x = 0
  for i in keys: x = x or (1 shl i)
  x

proc holds(x: int, key: int8): bool = (x and (1 shl key)) != 0
proc without(x: int, key: int8): int = x xor (1 shl key)

proc getNeighbours(v: Vertex): seq[(Vertex,string)] =
  let
    (p1, valve, released, mins, unturned) = v
    (flowRate, ns) = valves[valve]
    m = mins - 1

  if m < 1: return

  var vs = newSeq[(Vertex,string)]()
  # turn a valve
  if unturned.holds(valve) and flowRate > 0:
    vs.add(((p1, valve, m*flowRate + released, m, unturned.without(valve)), fmt"T {valve}"))
  # move
  for n in ns:
      vs.add(((p1, n, released, m, unturned), fmt"> {n}"))
  return vs

var dp = initTable[Vertex, int]()
var bestReleased = low(int)

proc dfs(start: Vertex): int =
  # echo fmt"running dfs with {start}"
  var
    maxReleased = low(int)
    (p1, _, released, mins, unturned) = start

  if start in dp: return dp[start]

  elif mins <= 1:
    if p1:
      let
        startValve = valveNames["AA"][2]
        p2Start: Vertex = (false,startValve,released,int8(26),unturned)
        res = dfs(p2Start)
      # dp[start] = res
      return res
    else:
      # dp[start] = released
      return released

  # if step mod 100000 == 0:
  #   let n = q.len
  #   echo fmt"Step {step}: queue size: {n}, maxReleased: {maxReleased}"
  # inc step

  for (u,nextMove) in getNeighbours(start):
    # echo fmt"recursing with neighbour {u}, nextMove {nextMove}"
    let
      uReleased = dfs(u)

    # echo fmt"u: {u}, uReleased: {uReleased}, maxReleased: {maxReleased}, best ever: {bestReleased}"
    if uReleased > maxReleased:
      maxReleased = uReleased
      if maxReleased > bestReleased:
        bestReleased = maxReleased
        echo fmt"new best neighbour u: {u}, maxReleased: {maxReleased}"

  let res = maxReleased
  if mins > 5:
    dp[start] = res
  res

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
  i += 1

for k,v in valveNames:
  let (flowRate, dests, i) = v
  valves[i] = (flowRate, dests.mapIt(valveNames[it][2]))

echo valves

let
  # start: Vertex = ("AA","AA",0,26,valves.keys.toSeq.toHashSet,moves)
  startValve = valveNames["AA"][2]
  # start: Vertex = (startValve,startValve,0,26,encodeValves(valves.keys.toSeq))
  start: Vertex = (true,startValve,0,int8(26),encodeValves(valves.keys.toSeq))
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"starting unturned: {valves.keys.toSeq}"
echo dfs(start)
echo fmt"Initial state: {valves.keys.toSeq} => {encodeValves(valves.keys.toSeq):#b}"

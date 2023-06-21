import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# vertex needs to encode: turns left, ore, clay, obsidian, geodes, ore robots, clay robots, obsidian robots, geode robots
type Vertex = (int, int, int, int, int, int, int, int, int, string)
type Blueprint = object
    id: int
    oreOre: int
    clayOre: int
    obsidianOre: int
    obsidianClay: int
    geodeOre: int
    geodeObsidian: int

var blueprints: seq[Blueprint]
var blueprint: Blueprint

proc getNeighbours(v: Vertex, blueprint: Blueprint): seq[Vertex] =
  let
    (turns, ore, clay, obsidian, geodes, oreR, clayR, obsidianR, geodeR, moves) = v
    t = turns - 1

  if t < 1: return

  var vs = newSeq[Vertex]()
  # actions are wait, build (ore|clay|obsidian|geode) robot
  # wait, accumulate stuff from robots
  vs.add(((t, ore + oreR, clay + clayR, obsidian + obsidianR, geodes + geodeR, oreR, clayR, obsidianR, geodeR, moves & ", wait")))

  # build a robot of each type, if stuff available
  if ore >= blueprint.oreOre:
    vs.add(((t, ore + oreR - blueprint.oreOre, clay + clayR, obsidian + obsidianR, geodes + geodeR, oreR + 1, clayR, obsidianR, geodeR, moves & ", make ore robot")))
  if ore >= blueprint.clayOre:
    vs.add(((t, ore + oreR - blueprint.clayOre, clay + clayR, obsidian + obsidianR, geodes + geodeR, oreR, clayR + 1, obsidianR, geodeR, moves & ", make clay robot")))
  if ore >= blueprint.obsidianOre and clay >= blueprint.obsidianClay:
    vs.add(((t, ore + oreR - blueprint.obsidianOre, clay + clayR - blueprint.obsidianClay, obsidian + obsidianR, geodes + geodeR, oreR, clayR, obsidianR + 1, geodeR, moves & ", make obsidian robot")))
  if ore >= blueprint.geodeOre and obsidian >= blueprint.geodeObsidian:
    vs.add(((t, ore + oreR - blueprint.geodeOre, clay + clayR, obsidian + obsidianR - blueprint.geodeObsidian, geodes + geodeR, oreR, clayR, obsidianR, geodeR + 1, moves & ", make geode robot")))
  return vs

proc getApproximateOptimum(v: Vertex): int =
  # uhh
  v[0] * (2*v[8]+v[0])

# greedy approximation...
proc `<`(a, b: Vertex): bool =
  # a[2] >= b[2]
  # let
  #   aPossible = 1*a[2] + 1*getApproximateOptimum(a[4], a[3])
  #   bPossible = 1*b[2] + 1*getApproximateOptimum(b[4], b[3])
  let
    aPossible = a[1] + a[2] + a[3] + getApproximateOptimum(a)
    bPossible = b[1] + b[2] + a[3] + getApproximateOptimum(b)
  aPossible > bPossible

# highest result so far... 2082... 2297, 2543, 2615
proc bfs(start: Vertex): (int, string) =
  echo fmt"Running BFS on blueprint {blueprint.id}"

  var
    maxGeodes = 0
    bestMoves: string = ""
    q = initHeapQueue[Vertex]()
    visited = initHashSet[Vertex]()
    step = 0

  q.push(start)

  while q.len > 0:
    if step mod 100000 == 0:
      let n = q.len
      echo fmt"Step {step}: queue size: {n}, maxGeodes: {maxGeodes}, visited len: {visited.len}"
    inc step
    let
      v = q.pop
      (turns, ore, clay, obsidian, geodes, oreR, clayR, obsidianR, geodeR, moves) = v
      bestPossible = getApproximateOptimum(v)

    if geodes > maxGeodes:
      maxGeodes = geodes
      # bestMoves = moves
      echo fmt"new best v: {v}, maxGeodes: {maxGeodes}, bestPossible: {bestPossible}"

    if bestPossible >= maxGeodes:
      for state in getNeighbours(v, blueprint):
        let
          (_, uOre, uClay, uObsidian, uGeodes, _, _, _, _, uMoves) = state
        # echo fmt"u: {u}"
        if uGeodes > maxGeodes:
          maxGeodes = uGeodes
          bestMoves = uMoves
          echo fmt"new best neighbour u: {state}, maxGeodes: {maxGeodes}, bestPossible estimate was: {bestPossible}"
        if state notin visited:
          q.push(state)
          visited.incl(state)

  (maxGeodes, bestMoves)

for line in stdin.lines:
  var
    blueprintId: int
    oreOre: int
    clayOre: int
    obsidianOre: int
    obsidianClay: int
    geodeOre: int
    geodeObsidian: int

  if not scanf(line, "Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian.", blueprintId, oreOre, clayOre, obsidianOre, obsidianClay, geodeOre, geodeObsidian):
    raise newException(ValueError, fmt"Bad input: {line}")

  let blueprint = Blueprint(id: blueprintId, oreOre: oreOre, clayOre: clayOre, obsidianOre: obsidianOre, obsidianClay: obsidianClay, geodeOre: geodeOre, geodeObsidian: geodeObsidian)
  # echo line
  # echo blueprint
  blueprints.add(blueprint)

echo blueprints
blueprint = blueprints[0]

let start: Vertex = (24, 0, 0, 0, 0, 1, 0, 0, 0, "start")
echo fmt"neighbours of start node: {getNeighbours(start, blueprints[0])}"
echo fmt"initial approximate optimum: {getApproximateOptimum(start)}"
echo bfs(start)

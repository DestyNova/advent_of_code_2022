import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# vertex needs to encode: turns left, ore, clay, obsidian, geodes, ore robots, clay robots, obsidian robots, geode robots
type Vertex = (int, int, int, int, int, int, int, int, int, string)
type CacheEntry = (int, int, int, int, int, int, int, int, int)
type Blueprint = object
    id: int
    oreOre: int
    clayOre: int
    obsidianOre: int
    obsidianClay: int
    geodeOre: int
    geodeObsidian: int

var blueprints: seq[Blueprint]

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
  let (turns, ore, clay, obsidian, geodes, oreR, clayR, obsidianR, geodeR, moves) = v
  geodes + turns * geodeR + ceil(turns*(turns-1)/2).int
  #v[4] + movesLeft * (((v[5]+1) div 8) + ((v[6]+1) div 4) + ((v[7]+1) div 2) + v[8])

# greedy approximation...
proc `<`(a, b: Vertex): bool =
  # a[2] >= b[2]
  let
    aPossible = getApproximateOptimum(a)
    bPossible = getApproximateOptimum(b)
  # let
  #   aPossible = a[0] + a[1] + a[2] + a[3] + a[4]
  #   bPossible = b[0] + b[1] + b[2] + a[3] + a[4]
  aPossible > bPossible

var maxGeodes: int = 0
var bestMoves: string = ""

proc dfs(v: Vertex, blueprint: Blueprint, dp: var Table[CacheEntry, (int,string)]): (int, string) =
  # echo fmt"Running DFS on blueprint {blueprint.id}"

  let (turns, ore, clay, obsidian, geodes, oreR, clayR, obsidianR, geodeR, moves) = v
  let cacheEntry: CacheEntry = (turns, ore, clay, obsidian, geodes, oreR, clayR, obsidianR, geodeR)
  let h = getApproximateOptimum(v)

  if cacheEntry in dp: return dp[cacheEntry]
  if h <= maxGeodes: return (0, moves)

  if geodes > maxGeodes:
    maxGeodes = geodes
    # bestMoves = moves
    echo fmt"new best v: {v}, maxGeodes: {maxGeodes}"

  for state in getNeighbours(v, blueprint):
    let
      (uGeodes, uMoves) = dfs(state, blueprint, dp)
    # echo fmt"u: {u}"
    if uGeodes > maxGeodes:
      maxGeodes = uGeodes
      bestMoves = uMoves
      echo fmt"new best neighbour u: {state}, maxGeodes: {maxGeodes}"

  let res = (maxGeodes, bestMoves)

  if turns > 1:
    dp[cacheEntry] = res
  res

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

  let blueprint = Blueprint(id: int(blueprintId), oreOre: int(oreOre), clayOre: int(clayOre), obsidianOre: int(obsidianOre), obsidianClay: int(obsidianClay), geodeOre: int(geodeOre), geodeObsidian: int(geodeObsidian))
  # echo line
  # echo blueprint
  blueprints.add(blueprint)

echo blueprints

let
  start: Vertex = (25, 0, 0, 0, 0, 1, 0, 0, 0, "start")
echo fmt"neighbours of start node: {getNeighbours(start, blueprints[0])}"
echo fmt"initial approximate optimum: {getApproximateOptimum(start)}"

let res = collect:
  for b in blueprints:
    var dp = initTable[CacheEntry, (int, string)]()
    dfs(start, b, dp)[0] * b.id

echo res.sum

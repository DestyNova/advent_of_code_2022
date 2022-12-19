import std/[algorithm, sequtils, strformat, strscans, strutils, sets, heapqueue, tables, sugar, math]

# vertex needs to encode: turns left, ore, clay, obsidian, geodes, ore robots, clay robots, obsidian robots, geode robots
type Vertex = object
  turns: int
  ore: int
  clay: int
  obsidian: int
  geodes: int
  oreR: int
  clayR: int
  obsidianR: int
  geodeR: int
  moves: string

# This is a bit annoying in Nim.
proc newVertex(turns: int, ore: int, clay: int, obsidian: int, geodes: int, oreR: int, clayR: int, obsidianR: int, geodeR: int, moves: string): Vertex = Vertex(
  turns: turns,
  ore: ore,
  clay: clay,
  obsidian: obsidian,
  geodes: geodes,
  oreR: oreR,
  clayR: clayR,
  obsidianR: obsidianR,
  geodeR: geodeR,
  moves: moves)

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

proc getNeighbours(v: Vertex): seq[Vertex] =
  let
    t = v.turns - 1

  if v.turns < 1: return

  var vs = newSeq[Vertex]()
  # actions are wait, build (ore|clay|obsidian|geode) robot
  # build a robot of each type, if stuff available
  if t > 0:
    if v.ore >= blueprint.oreOre:
      vs.add(newVertex(t, v.ore + v.oreR - blueprint.oreOre, v.clay + v.clayR, v.obsidian + v.obsidianR, v.geodes + v.geodeR, v.oreR + 1, v.clayR, v.obsidianR, v.geodeR, v.moves & "o"))
    if v.ore >= blueprint.clayOre:
      vs.add(newVertex(t, v.ore + v.oreR - blueprint.clayOre, v.clay + v.clayR, v.obsidian + v.obsidianR, v.geodes + v.geodeR, v.oreR, v.clayR + 1, v.obsidianR, v.geodeR, v.moves & "c"))
    if v.ore >= blueprint.obsidianOre and v.clay >= blueprint.obsidianClay:
      vs.add(newVertex(t, v.ore + v.oreR - blueprint.obsidianOre, v.clay + v.clayR - blueprint.obsidianClay, v.obsidian + v.obsidianR, v.geodes + v.geodeR, v.oreR, v.clayR, v.obsidianR + 1, v.geodeR, v.moves & "b"))
    if v.ore >= blueprint.geodeOre and v.obsidian >= blueprint.geodeObsidian:
      vs.add(newVertex(t, v.ore + v.oreR - blueprint.geodeOre, v.clay + v.clayR, v.obsidian + v.obsidianR - blueprint.geodeObsidian, v.geodes + v.geodeR, v.oreR, v.clayR, v.obsidianR, v.geodeR + 1, v.moves & "g"))
  # wait, accumulate stuff from robots
  vs.add(newVertex(t, v.ore + v.oreR, v.clay + v.clayR, v.obsidian + v.obsidianR, v.geodes + v.geodeR, v.oreR, v.clayR, v.obsidianR, v.geodeR, v.moves & "w"))

  return vs

proc getApproximateOptimum(v: Vertex): int =
  # uhh
  v.turns * (v.oreR + v.clayR + v.obsidianR + v.geodeR + v.turns) div 2

# greedy approximation...
proc `<`(a, b: Vertex): bool =
  # a[2] >= b[2]
  # let
  #   aPossible = 1*a[2] + 1*getApproximateOptimum(a[4], a[3])
  #   bPossible = 1*b[2] + 1*getApproximateOptimum(b[4], b[3])
  let
    aPossible = a.ore + 2*a.clay + 2*a.obsidian + 4*a.geodes + getApproximateOptimum(a)
    bPossible = b.ore + 2*b.clay + 2*b.obsidian + 4*b.geodes + getApproximateOptimum(b)
  aPossible > bPossible

var dp = initTable[Vertex, (int, string)]()
var maxGeodes = 0
var bestMoves: string = ""

proc dfs(v: Vertex): (int, string) =
  # echo fmt"Running DFS on blueprint {blueprint.id}"

  let
    geodes = v.geodes
    moves = v.moves
  if v in dp: return dp[v]

  elif geodes + getApproximateOptimum(v) < maxGeodes:
    return (geodes, moves)

  if geodes > maxGeodes:
    maxGeodes = geodes
    bestMoves = moves
    echo fmt"new best v: {v}, maxGeodes: {maxGeodes}, approximateOptimum: {getApproximateOptimum(v)}"

  for state in getNeighbours(v):
    let
      (uGeodes, uMoves) = dfs(state)
    # echo fmt"neighbour u: {state}, maxGeodes: {maxGeodes}, approximateOptimum: {getApproximateOptimum(state)}"
    if uGeodes > maxGeodes:
      maxGeodes = uGeodes
      bestMoves = uMoves
      echo fmt"new best neighbour u: {state}, maxGeodes: {maxGeodes}, approximateOptimum: {getApproximateOptimum(state)}"

  let res = (maxGeodes, bestMoves)

  if v.turns > 3:
    dp[v] = res
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

  let blueprint = Blueprint(id: blueprintId, oreOre: oreOre, clayOre: clayOre, obsidianOre: obsidianOre, obsidianClay: obsidianClay, geodeOre: geodeOre, geodeObsidian: geodeObsidian)
  # echo line
  # echo blueprint
  blueprints.add(blueprint)

echo blueprints
blueprint = blueprints[1] # couldn't figure out a way to pass it to `<`

let
  start: Vertex = newVertex(24, 0, 0, 0, 0, 1, 0, 0, 0, ">")
echo fmt"neighbours of start node: {getNeighbours(start)}"
echo fmt"initial approximate optimum: {getApproximateOptimum(start)}"
echo dfs(start)

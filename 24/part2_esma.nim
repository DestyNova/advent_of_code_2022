import std/[strformat, strutils, sets, heapqueue, tables, options, sugar, sequtils]

type
  Coord = (int,int)
  Blizzard = (int,int,char)
  Blizzards = HashSet[Blizzard]
  State = (int,int,int,int)  # player (x,y), num moves, stage 0/1/2
  Vertex = ref object
    s: State
    f: int
    forgotten: Table[State,int]
    parent: Vertex

proc `$`(v: Vertex): string = fmt"Vertex(s: {v.s}, f: {v.f}, forgotten: {v.forgotten}, parent: {(if not isNil(v.parent): $v.parent.s else: $(-1))}"

const Inf = high(int)
const Dirs = {'<': (-1,0), '>': (1,0), '^': (0,-1), 'v': (0,1)}.toTable
var
  w, h: int
  blizzards: seq[Blizzards]

proc applyOffset(a: Coord,b: Coord): Coord =
  let
    (i,j) = a
    (dx,dy) = b
    i2 = i + dx + 2*w
    j2 = j + dy + 2*h
  (i2 mod w, j2 mod h)

proc getOffset(d: char): Coord = Dirs[d]

# cache all previously generated blizzard states since there'll be a reasonable finite number of them
proc step(i: int): Blizzards =
  if blizzards.len <= i:
    var g2: Blizzards

    for b in blizzards[i-1]:
      let
        (i,j,d) = b
        (i2,j2) = applyOffset((i,j),getOffset(d))
      g2.incl((i2,j2,d))
    blizzards.add(g2)
    g2
  else:
    blizzards[i]

proc getNeighbours(v: State): seq[State] =
  let
    (i,j,steps,stage) = v
    blizzards2 = step(steps+1)
    startPoint = (0,-1)
    endPoint = (w-1,h)

  var vs = newSeq[State]()

  if stage >= 3: return vs # already reached the end

  # wait or move
  for (dx,dy) in [(0,0),(1,0),(-1,0),(0,1),(0,-1)]:
    let
      p = (i + dx, j + dy)
      (i2,j2) = p
      validSpace = i2 >= 0 and i2 < w and j2 >= 0 and j2 < h
      occupied = (i2,j2,'<') in blizzards2 or (i2,j2,'>') in blizzards2 or (i2,j2,'^') in blizzards2 or (i2,j2,'v') in blizzards2

    if validSpace and not occupied: vs.add((i2,j2,steps+1,stage))
    elif p == startPoint and stage == 1: vs.add((i2,j2,steps+1,stage+1))
    elif p == endPoint and stage != 1: vs.add((i2,j2,steps+1,stage+1)) # reached endPoint
    elif p == (i,j) and not occupied: vs.add((i,j,steps+1,stage))  # wait

  return vs

proc getApproximateOptimum(v: State): int =
  let
    (i,j,_,stage) = v
    x = if stage == 1: i else: w-i-1
    y = if stage == 1: j+1 else: h-j
  x + y + max(0,(2-stage)*(w-1 + h+1))

proc `<`(a, b: Vertex): bool = a.f < b.f

proc isGoal(s: State): bool = (s[0],s[1]) == (w-1,h) and s[3] >= 2

# SMA*+: https://easychair.org/publications/open/TL2M
proc search(start: State, nodeLimit: int = 100): int =
  var
    minMoves = Inf
    q = initHeapQueue[Vertex]() # open?
    nodeCount = 1  # will this diverge from actual queue length?
    t = 1

  let
    forgotten = initTable[State,int]()
    v0 = Vertex(s: start, f: getApproximateOptimum(start), forgotten: forgotten, parent: nil)
  q.push(v0)

  # I think SMA*+ works basically like A*, but:
  #
  # * When maximum queue size reached, pop the vertex with the worst F-value (i.e. priority)
  # * Remember "best-forgotten child" in all parent nodes... (how? when and where do we store them?)
  # * Note: only really works if the max memory allowance is sufficient to store the entire path (of whatever node format)
  #   * ...in which case we mark longer paths with an f-value of infinity?
  #   * The overhead of MA*, SMA* and SMA*+ seem enormous... nodes refer to their parents and update them, so I guess
  #     they were originally implemented in C, Java or other pointery language?
  # * Consider culling heuristic (for problems with many similar f-values): c(n) = f(n)/ ln(d(n) + e)
  echo fmt"Initial queue: {q}"
  while q.len > 0:
    var node = q.pop
    let
      (i,j,moves,stage) = node.s
      bestPossible = moves + getApproximateOptimum(node.s)

    if isGoal(node.s): return moves
  
    if t mod 1000000 == 0:
      let n = q.len
      echo fmt"Step {t}: {node}, queue size: {n}, nodeCount: {nodeCount}, minMoves: {minMoves}, current guess: {bestPossible}, stage: {stage}"
      # Debug: print the priority queue contents.
      # for x in 0..q.len-1:
      #   echo fmt"{x}: {q[x]}"
    inc t

    if moves < minMoves and (i,j) == (w-1,h) and stage >= 3:
      minMoves = moves
      echo fmt"v: {node.s}, new minMoves: {minMoves}, bestPossible: {bestPossible}"
      return minMoves

    # re-expand
    if node.forgotten.len > 0:
      # echo fmt"Found forgotten stuff. Maybe the ref thing does work? {node}"
      for u, uF in node.forgotten:
        q.push(Vertex(s: u, f: uF, forgotten: initTable[State,int](), parent: node))
        inc nodeCount
      node.forgotten.clear
    else:
      for u in getNeighbours(node.s):
        let
          uF = max(node.f, moves + 1 + getApproximateOptimum(u))
          uForgotten = initTable[State,int]()
          v2 = Vertex(s:u, f:uF, forgotten:uForgotten, parent:node)

        # not sure what it means to update the successor node's f-score here...
        # unless it's referenced from another node's forgotten list or... something. Otherwise isn't this
        # update discarded? Who is supposed to see the update?
        # I think this is why the paper refers to a "successor list". I'm not a fan of that because we're
        # discovering the successors lazily by exploring an infinite state/action graph, rather than a
        # fixed grid.
        # if not isGoal(u) and getNeighbours(u).len == 0: u.f = Inf

        # echo fmt"Found neighbour {v2}; adding to queue..."
        if isGoal(u) or getNeighbours(u).len > 0 or (moves + 1 < nodeCount):
          q.push(v2)
          inc nodeCount

    # what's the point in updating the parents if they've been popped and never get stored elsewhere? wtf mate
    # actually I think they are, via a reference from the children. Weird. Either we handle that as a reference,

    # SMA*+ pruning... something is almost certainly wrong here.
    while nodeCount > nodeLimit:
      let first = q[0]
      var pruneIdx = q.len-1
      var pruned = q[pruneIdx]
      # walk backwards from the end since heapqueue values aren't monotonically accessible...
      while pruned.f == first.f:
        dec pruneIdx
        assert pruneIdx > 0
        pruned = q[pruneIdx]
      q.del(pruneIdx)
      # remove u from "successor list" of uParent, but... we don't have that?
      # add _state_ to forgotten f-cost table of the parent
      # echo fmt"About to prune: {pruned}"
      # But... after a while the root node ends up here, and it obviously doesn't have a parent node...
      # Adding a check for that case, but not sure if the behaviour is correct now. How is it supposed to work?
      dec nodeCount
      if not isNil(pruned.parent):
        # echo fmt"pruning: {pruned}"
        pruned.parent.forgotten[pruned.s] = pruned.f
        pruned.parent.f = min(pruned.parent.forgotten.values.toSeq)  # update f(parent) to min of forgotten f-costs
        if q.find(pruned.parent) == -1:
          # echo fmt"Adding updated {pruned.parent} back to queue"
          q.push(pruned.parent)
        # q.push(pruned.parent) # can we just do this instead of a linear scan??
      # else:
      #   echo "No idea what to do when pruning the root node... I'll just leave its forgotten set alone, but... eh..."
      #   echo fmt"Or is it the root? {pruned}"
  minMoves

var blizzardsInit: HashSet[Blizzard]

var j = 0
for line in stdin.lines:
  w = line.len-2
  h = j
  if line[2] == '#': continue
  for i in 0..line.len-1:
    if line[i] in "<>^v":
      blizzardsInit.incl((i-1,j,line[i]))
  inc j

blizzards.add(blizzardsInit)
let s0: State = (0,-1,0,0)
# echo fmt"s0: {s0}"
# echo fmt"w,h: {w}, {h}, neighbours of start node: {getNeighbours(s0)}"
echo fmt"neighbours of near-end node: {getNeighbours((2,2,0,2))}"
echo fmt"initial approximate optimum: {getApproximateOptimum(s0)}"
let moves = search(s0)
echo moves

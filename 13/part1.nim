import std/[math, sequtils, strformat, strutils]

let g = stdin.readAll.split("\n\n").toSeq.mapIt(it.split("\n"))

type
  PacketKind = enum pInt, pList
  Packet = ref object
    case kind:PacketKind
    of pInt: v: int
    of pList: vs: seq[Packet]

proc `$`(p: Packet): string =
  case p.kind
  of pInt: fmt"IntPacket({p.v})"
  of pList:
    let inners = p.vs.mapIt($it).join(",")
    fmt"ListPacket({inners})"

proc readTerms(s: string, offset: int): (Packet, int) =
  var i = offset
  let al = len(s)
  var buf = ""
  var terms: seq[Packet] = @[]

  while i < al:
    var c = s[i]
    inc i

    if c == '[':
      let (innerTerms, i2) = readTerms(s, i)
      i = i2
      terms.add(innerTerms)
    elif c == ']':
      break
    elif c == ',':
      if buf.len > 0:
        let packet = Packet(kind: pInt, v: parseInt(buf))
        terms.add(packet)
        buf = ""
    else:
      buf = buf & $c

  if buf.len > 0:
    let packet = Packet(kind: pInt, v: parseInt(buf))
    terms.add(packet)
  return (Packet(kind: pList, vs: terms), i)

# -1: x < y, 0: x == y, 1: x > y
proc compareTerms(x: Packet, y: Packet): int =
  let comp = fmt"{x.kind},{y.kind}"
  case comp
  of "pInt,pInt":
    return if x.v < y.v: -1 elif x.v == y.v: 0 else: 1
  of "pList,pList":
    let
      xTerms = x.vs
      yTerms = y.vs
      xCount = len(xTerms)
      yCount = len(yTerms)

    for i in 0..max(xCount, yCount)-1:
      if i >= xCount: return -1
      if i >= yCount: return 1
      let r = compareTerms(xTerms[i], yTerms[i])
      if r != 0: return r
    return 0
  else:
    if x.kind == pInt: return compareTerms(Packet(kind: pList, vs: @[x]), y)
    if y.kind == pInt: return compareTerms(x, Packet(kind: pList, vs: @[y]))

var indices: seq[int] = @[]

for i in 0..g.len-1:
  let
    p = g[i]
    (aTerms,_) = readTerms(p[0], 0)
    (bTerms,_) = readTerms(p[1], 0)
    comp = compareTerms(aTerms, bTerms)

  if comp < 1: indices.add(i+1)

echo sum(indices)

import sequtils,sets,strutils

proc getPriority(lines: seq[string]): int =
  let common = lines.mapIt(it.toSeq.toHashSet).foldl(a * b).toSeq[0]
  common.ord - (if common.isUpperAscii(): 38 else: 'a'.ord - 1)

let inp = stdin.lines.toSeq
echo inp.distribute(inp.len div 3).foldl(a + getPriority(b), 0)

import sequtils, strutils

var stacks: seq[seq[char]]

for line in stdin.lines:
  let numStacks = (line.len + 1) div 4

  if "[" in line:
    for i in 0..numStacks-1:
      if i >= stacks.len:
        stacks.add(@[])
      if line[4*i] == '[':
        stacks[i].add(line[4*i + 1])
  elif "move" in line:
    let parts = line.split()
    let n = parts[1].parseInt
    let source = parts[3].parseInt
    let dest = parts[5].parseInt

    var buf: seq[char] = @[]
    for i in 0..n-1:
      buf.add(stacks[source-1][0])
      stacks[source-1].delete(0)
    stacks[dest-1] = buf & stacks[dest-1]

echo stacks.mapIt(it[0]).join("")

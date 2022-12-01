import strutils

var maxC = 0
var line = ""

var c = 0
for line in stdin.lines:
  if line == "":
    maxC = max(maxC, c)
    c = 0
  else:
    c += parseInt(line)

echo maxC

import std/strutils

var
    x = 1
    t = 1
    cycles = 0
    s = 0

for line in stdin.lines:
  let
    bits = line.split()
    insn = bits[0]
    operand = if insn == "addx": bits[1].parseInt else: 0

  case insn:
    of "noop":
      cycles = 1
    else: cycles = 2

  while cycles > 0:
    if insn == "addx" and cycles == 1:
      x += operand
    t += 1
    cycles -= 1
    if (t+20) mod 40 == 0: s += t*x

echo s

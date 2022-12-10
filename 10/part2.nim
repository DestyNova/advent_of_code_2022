import std/strutils

var
    x = 1
    t = 0
    cycles = 0
    drawPos = 0

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
    # draw to CRT first
    if drawPos == (x+39) mod 40 or drawPos == x mod 40 or drawPos == x+1 mod 40:
      stdout.write("#")
    else:
      stdout.write(".")

    drawPos += 1
    if drawPos == 40:
      drawPos = 0
      echo ""

    cycles -= 1
    t += 1
    if insn == "addx" and cycles == 0:
      x += operand

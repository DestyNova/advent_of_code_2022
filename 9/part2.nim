import std/strutils, std/strformat, std/sets

proc renderGrid(hx,hy: int, tails: array[0..8, tuple[tx, ty: int]]): void =
  let
    w = 6
    h = 5
  for j in 1..h:
    for i in 0..w-1:
      var wrote = false
      if hx == i and h - hy == j:
        stdout.write("H")
        wrote = true
      else:
        for z in 0..8:
          let (tx,ty) = tails[z]
          if (tx,h - ty) == (i,j) and not wrote:
            stdout.write(fmt"{z+1}")
            wrote = true
        if not wrote:
          stdout.write(".")
    echo ""
  echo "\n--------\n"
      

var
    seen = @[(0,0)].toHashSet
    tails = [(0,0),(0,0),(0,0),(0,0),(0,0),(0,0),(0,0),(0,0),(0,0)]
    hx = 0
    hy = 0

for line in stdin.lines:
  let
    bits = line.split()
    dir = bits[0]
    steps = bits[1].parseInt

  for step in 1..steps:
    case dir:
      of "R": hx += 1
      of "U": hy += 1
      of "L": hx -= 1
      of "D": hy -= 1

    # echo line
    # renderGrid(hx,hy,tails)

    for i in 0..8:
      var (tx,ty) = tails[i]
      let (fx,fy) = if i == 0: (hx,hy) else: tails[i-1]
      while true:
        let dist = max(abs(fx-tx),abs(fy-ty))
        if dist > 1:
          if fx > tx and fy > ty:
            tx += 1
            ty += 1
          elif fx > tx and fy < ty:
            tx += 1
            ty -= 1
          elif fx < tx and fy > ty:
            tx -= 1
            ty += 1
          elif fx < tx and fy < ty:
            tx -= 1
            ty -= 1
          elif fx > tx+1:
            tx += 1
          elif fy > ty+1:
            ty += 1
          elif fx < tx-1:
            tx -= 1
          elif fy < ty-1:
            ty -= 1
          if i == 8:
            seen.incl((tx,ty))
        else:
          break
      tails[i] = (tx,ty)

echo seen.len

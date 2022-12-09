import std/[tables, strutils]

var
    seen = @[((0,0),0)].toTable
    tx = 0
    ty = 0
    hx =0
    hy = 0

for line in stdin.lines:
  let
    bits = line.split()
    dir = bits[0]
    steps = bits[1].parseInt

  echo ("Head",hx,hy)
  echo ("Tail",tx,ty)
  echo (dir,steps)

  case dir:
    of "R": hx += steps
    of "U": hy += steps
    of "L": hx -= steps
    of "D": hy -= steps
    else: echo "WAT?"

  echo (hx,hy)

  while true:
    let dist = max(abs(hx-tx),abs(hy-ty))
    echo dist
    if dist > 1:
      echo "Moving tail"
      if hx > tx and hy > ty:
        tx += 1
        ty += 1
      elif hx > tx and hy < ty:
        tx += 1
        ty -= 1
      elif hx < tx and hy > ty:
        tx -= 1
        ty += 1
      elif hx < tx and hy < ty:
        tx -= 1
        ty -= 1
      elif hx > tx+1:
        tx += 1
      elif hy > ty+1:
        ty += 1
      elif hx < tx-1:
        tx -= 1
      elif hy < ty-1:
        ty -= 1
      seen[(tx,ty)] = 0
      echo (tx,ty)
    else:
      break

  echo seen.len

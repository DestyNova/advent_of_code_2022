import std/[math, sets, strformat, strutils]

proc renderGrid(knots: array[0..9, tuple[tx, ty: int]]): void =
  let
    w = 6
    h = 5
  for j in 1..h:
    for i in 0..w-1:
      var wrote = false
      for z in 0..9:
        let (tx,ty) = knots[z]
        if (tx,h - ty) == (i,j) and not wrote:
          let c = if z == 0: "H" else: $(z+1)
          stdout.write(fmt"{c}")
          wrote = true
      if not wrote:
        stdout.write(".")
    echo ""
  echo "\n--------\n"
      

var
    seen = @[(0,0)].toHashSet
    knots = [(0,0),(0,0),(0,0),(0,0),(0,0),(0,0),(0,0),(0,0),(0,0),(0,0)]

for line in stdin.lines:
  let
    bits = line.split()
    dir = bits[0]
    steps = bits[1].parseInt

  for step in 1..steps:
    case dir:
      of "R": knots[0][0] += 1
      of "U": knots[0][1] += 1
      of "L": knots[0][0] -= 1
      of "D": knots[0][1] -= 1

    # echo line
    # renderGrid(knots)

    for i in 1..9:
      var (tx,ty) = knots[i]
      let (fx,fy) = knots[i-1]
      if abs(fx-tx) > 1 or abs(fy-ty) > 1:
        tx += sgn(fx-tx)
        ty += sgn(fy-ty)
        knots[i] = (tx,ty)

    seen.incl(knots[9])

echo seen.len

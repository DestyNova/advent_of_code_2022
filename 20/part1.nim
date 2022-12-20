import std/[sequtils, sets, strformat, strutils, sugar, tables, math]

let input = stdin.lines.toSeq.map(parseInt)

# original index, new index, value
var nums: Table[int,int]
var indices: Table[int,int]
var revIndices: Table[int,int]

for i in 0..input.len-1:
  nums.add(i,input[i])
  indices.add(i,i)
  revIndices.add(i,i)

proc realModulo(a,b: int): int =
  a - ((a div b)*b)

let ns = input.len

# mix
for j in 0..ns-1:
  let i = indices[j]
  let n = input[j]
  # 0 0 -2 0
  # 0 -2 0 0
  # 0 0 0 -2 (wrapped)
  # 0 0 -1 0
  # 0 -1 0 0 (no wrap)
  # if n < 0 and moving left n times takes us to i<=0, go right instead, ns - n - 1?
  # else swap left x times
  # what if n is much bigger than ns?
  # 0 0 -7 0
  # 0 -7 0 0
  # 0 0 0 -7
  # 0 0 -7 0
  # 0 -7 0 0
  # 0 0 0 -7
  # 0 0 -7 0
  # 0 -7 0 0
  # 21100 was too high, 12412 also too high
  # -1 0 0 0
  # 0 0 -1 0 ?
  #
  # -5 0 0 0
  # 0 0 -5 0
  # 0 -5 0 0
  # 0 0 0 -5
  # 0 0 -5 0
  # 0 -5 0 0
  #
  # 0 0 0 -5
  # 0 0 -5 0
  # 0 -5 0 0
  # 0 0 0 -5
  # 0 0 -5 0
  # 0 -5 0 0
  #
  # 0 0 4 0
  # 4 0 0 0
  # 0 4 0 0
  # 0 0 4 0
  # 4 0 0 0
  #
  # 3 0 0 0
  # 0 3 0 0
  # 0 0 3 0
  # 3 0 0 0
  #
  # 4 0 0 0
  # 0 4 0 0
  # 0 0 4 0
  # 4 0 0 0
  # 0 4 0 0
  #
  var
    x = (if n < 0 and n + i <= 0:
           # cycle right
           let shift = (n mod (ns-1))
           if shift + i <= 0: ns - 1 + shift else: shift
         elif n > 0 and n + i >= ns-1:
           # cycle left
           ((i + n) mod (ns-1)) - i
         else:
           n mod ns)
    oldI = i

  while n != 0 and x != 0:
    # get new idx of next n, which will be +/- 1 from its current real index
    let newI = oldI+sgn(x)
    # and destination value
    let tmp = nums[newI]
    # get original index of destination value
    let destOrigI = revIndices[newI]

    # echo fmt"swapping {i}: {n} from {oldI} to {newI}, displacing {tmp}"
    nums[newI] = n
    nums[oldI] = tmp
    # update reverse indices
    revIndices[newI] = j
    revIndices[oldI] = destOrigI
    indices[j] = newI
    indices[destOrigI] = oldI
    x -= sgn(x)
    oldI = newI

    if false:
      for z in 0..ns-1:
        stdout.write(fmt"{nums[z]} ")
      echo ""

# get grove numbers
var zIndex = -1
for i in 0..ns-1:
  if nums[i] == 0:
    zIndex = i
    break

let
  a = nums[(zIndex + 1000) mod ns]
  b = nums[(zIndex + 2000) mod ns]
  c = nums[(zIndex + 3000) mod ns]

echo (a,b,c)
echo sum([a,b,c])

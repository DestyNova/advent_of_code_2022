import std/strutils, std/sequtils, std/strscans, std/strformat, std/algorithm

type Monkey = object
  n: int
  starting: seq[int]
  op: char
  opVal: string
  check: int
  checkT: int
  checkF: int
  inspections: int

var
    monkeys: seq[Monkey] = @[]

for m in stdin.readAll.strip.split("\n\n"):
  echo "===="
  let ls = m.split("\n")
  # val n = parseInt(m[
  echo ls
  var
    name: int
    objs: string
    op: char
    opVal: string
    check: int
    checkT: int
    checkF: int

  echo ls[0]
  echo scanf(ls[0], "Monkey $i:", name)
  echo ls[1]
  echo scanf(ls[1], "  Starting items: $+", objs)
  var opInt: int
  if scanf(ls[2], "  Operation: new = old $c $i", op, opInt):
    opVal = $opInt
  else:
    discard scanf(ls[2], "  Operation: new = old $c $w", op, opVal)
  echo scanf(ls[3], "  Test: divisible by $i", check)
  echo scanf(ls[4], "    If true: throw to monkey $i", checkT)
  echo scanf(ls[5], "    If false: throw to monkey $i", checkF)

  let xs = objs.split(",")
  echo fmt"{name}, [{objs}={xs}], {op} / {opVal}, {check}? {checkT} / {checkF}"

  let monkey = Monkey(n: name, starting: objs.split(", ").map(parseInt), op: op, opVal: opVal, check: check, checkT: checkT, checkF: checkF, inspections: 0)
  echo $monkey
  monkeys.add(monkey)

echo "\n####\n"

for round in 1..20:
  echo fmt"STARTING ROUND {round}"

  for i in 0..monkeys.len-1:
    var m = monkeys[i]
    echo fmt"Dealing with monkey {m}"

    while m.starting.len > 0:
      m.inspections += 1
      let worry = m.starting[0]
      echo fmt"worry: {worry}, opVal: {m.opVal}"
      echo fmt"starting: {m.starting}"
      m.starting.delete(0)
      echo fmt"starting AFTER DELETE: {m.starting}"

      let opVal = case m.opVal:
                    of "old": worry
                    else: parseInt(m.opVal)

      let w = case m.op:
                of '+': worry + opVal
                of '-': worry - opVal
                of '*': worry * opVal
                else: raise newException(ValueError, "unknown op")
      let w2 = w div 3
      echo fmt"old: {worry}, new: {w}, {w2}"

      let target = if w2 mod m.check == 0: m.checkT else: m.checkF
      echo fmt"throwing {w2} to {target}"
      monkeys[target].starting.add(w2)

    echo fmt"done with monkey: {m} after {m.inspections} inspections"
    monkeys[i] = m        # why do we have to reassign this?? was it a copy?

let action = monkeys.mapIt(it.inspections).sorted.reversed
echo action[0] * action[1]

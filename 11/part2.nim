import std/[algorithm, sequtils, strformat, strscans, strutils]

type Monkey = object
  n: int
  held: seq[int]
  op: char
  opVal: string
  check: int
  checkT: int
  checkF: int
  inspections: int

var monkeys: seq[Monkey] = @[]

for m in stdin.readAll.strip.split("\n\n"):
  let ls = m.split("\n")
  var
    name: int
    objs: string
    op: char
    opVal: string
    check: int
    checkT: int
    checkF: int

  assert scanf(ls[0], "Monkey $i:", name)
  assert scanf(ls[1], "  Starting items: $+", objs)
  assert scanf(ls[2], "  Operation: new = old $c $+", op, opVal)
  assert scanf(ls[3], "  Test: divisible by $i", check)
  assert scanf(ls[4], "    If true: throw to monkey $i", checkT)
  assert scanf(ls[5], "    If false: throw to monkey $i", checkF)

  let monkey = Monkey(
    n: name,
    held: objs.split(", ").map(parseInt),
    op: op,
    opVal: opVal,
    check: check,
    checkT: checkT,
    checkF: checkF,
    inspections: 0)
  monkeys.add(monkey)

let megaCheck = monkeys.mapIt(it.check).foldl(a*b)

let rounds = 10000
for round in 1..rounds:

  for m in monkeys.mitems:

    while m.held.len > 0:
      m.inspections += 1
      let worry = m.held[0]
      m.held.delete(0)

      let opVal = case m.opVal:
                    of "old": worry
                    else: parseInt(m.opVal)

      let w = case m.op:
                of '+': worry + opVal
                of '-': worry - opVal
                of '*': worry * opVal
                else: raise newException(ValueError, "unknown op")
      let w2 = w mod megaCheck

      let target = if w2 mod m.check == 0: m.checkT else: m.checkF
      monkeys[target].held.add(w2)

let inspections = monkeys.mapIt(it.inspections)
echo fmt"inspections: {inspections}"
let action = inspections.sorted.reversed
echo action[0] * action[1]

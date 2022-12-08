import std/sequtils, std/strscans, std/strformat, std/math

type
  Dir = object
    name: string
    files: int
    dirs: seq[Dir]

let
  totalSpace = 70000000
  requiredSpace = 30000000
  inp = stdin.lines.toSeq

# UGH
var
  index = 1
  sizes = newSeq[int]()

func getDirSize(d: Dir): int =
  d.files + d.dirs.map(getDirSize).sum

proc readDir(name: string, inp: seq[string]): Dir =
  var dirFileSize = 0
  var subDirs = newSeq[Dir]()

  for i in 1..500:
    var nextLine = (if index >= inp.len: "" else: inp[index])
    var deeperDir: string

    if nextLine == "$ cd .." or nextLine == "":
      index += 1
      result = Dir(name: name, files: dirFileSize, dirs: subDirs)

      if name != "/":
        let totalSize = getDirSize(result)
        sizes.add(totalSize)
      return

    elif nextLine == "$ ls":
      # get sizes
      while true:
        index += 1
        if index >= inp.len:
          break
        nextLine = inp[index]

        var fileSize = 0

        if nextLine[0] == '$':
          break
        elif scanf(nextLine, "$i", fileSize):
          dirFileSize += fileSize

    elif scanf(nextLine, "$$ cd $w", deeperDir):
      index += 1
      subDirs.add(readDir(deeperDir, inp))

let
  root = readDir("/", inp)
  totalSize = getDirSize(root)
  minToDelete = requiredSpace - (totalSpace - totalSize)

echo min(sizes.filterIt(it >= minToDelete))

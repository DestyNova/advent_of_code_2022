import std/sequtils, std/strscans, std/strformat, std/math

type
  Dir = object
    name: string
    files: int
    dirs: seq[Dir]


let inp = stdin.lines.toSeq

# UGH
var index = 1
var sizes = newSeq[int]()

proc getDirSize(d: Dir): int =
  d.files + d.dirs.map(getDirSize).sum

proc readDir(name: string, inp: seq[string]): Dir =
  var deeperDir: string

  var dirFileSize = 0
  var subDirs = newSeq[Dir]()

  for i in 1..500:
    var nextLine = (if index >= inp.len: "" else: inp[index])

    if nextLine == "$ cd .." or nextLine == "":
      index += 1
      result = Dir(name: name, files: dirFileSize, dirs: subDirs)

      let totalSize = getDirSize(result)
      if totalSize <= 100000:
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

discard readDir("/", inp)
echo sizes.sum

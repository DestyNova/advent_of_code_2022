import std/setutils

let chunkSize = 14

for line in stdin.lines:
  for i in 0..(line.len-chunkSize-1):
    let uniq = line[i..i+chunkSize-1].toSet.len
    if uniq == chunkSize:
      echo $(i + chunkSize)
      break

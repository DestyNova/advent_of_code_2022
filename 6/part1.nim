import std/setutils

for line in stdin.lines:
  for i in 0..(line.len-5):
    let uniq = line[i..i+3].toSet.len
    if uniq == 4:
      echo $(i + 4)
      break

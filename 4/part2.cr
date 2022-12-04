puts STDIN.each_line.reduce(0) { |acc, line|
  ab = line.split(",").map{|x| x.split("-")}
  a = ab[0]
  b = ab[1]
  aLow = a[0].to_i
  aHigh = a[1].to_i
  bLow = b[0].to_i
  bHigh = b[1].to_i

  isOverlap = ((bLow..bHigh).includes?(aLow)) || ((bLow..bHigh).includes?(aHigh)) || ((aLow..aHigh).includes?(bLow)) || ((aLow..aHigh).includes?(bHigh))
  acc + (isOverlap ? 1 : 0)
}

puts STDIN.each_line.reduce(0) { |acc, line|
  puts line
  ab = line.split(",").map{|x| x.split("-")}
  a = ab[0]
  b = ab[1]
  aLow = a[0].to_i
  aHigh = a[1].to_i
  bLow = b[0].to_i
  bHigh = b[1].to_i

 isContainment = ((aLow >= bLow && aHigh <= bHigh) || (bLow >= aLow && bHigh <= aHigh))
  acc + (isContainment ? 1 : 0)
}

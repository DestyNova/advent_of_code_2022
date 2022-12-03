puts STDIN.each_line.reduce(0) { |acc, line|
  s = line.size() // 2
  a,b = line[0..s-1],line[s..]
  common = (a.chars.to_set & b.chars.to_set).to_a[0]
  priority = common.ord - (common.uppercase? ? 38 : 'a'.ord - 1)
  acc + priority
}

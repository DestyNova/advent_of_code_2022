puts STDIN.each_line.to_a.in_groups_of(3, "").reduce(0) { |acc,lines|
  common = lines.map {|s| s.chars.to_set}.reduce {|a,s| a & s}.to_a[0]
  priority = common.ord - (common.uppercase? ? 38 : 'a'.ord - 1)
  acc + priority
}

def get_outcome(me, elf)
  case me
  when 'X';{'A'=>3, 'B'=>1, 'C'=>2}[elf]
  when 'Y';{'A'=>1, 'B'=>2, 'C'=>3}[elf] + 3
  when 'Z';{'A'=>2, 'B'=>3, 'C'=>1}[elf] + 6
  else; raise "Unknown move: #{me}, #{elf}"
  end
end

puts STDIN.each_line.reduce(0) { |acc, line|
  elf, me = line[0], line[2]
  acc + get_outcome(me, elf)
}

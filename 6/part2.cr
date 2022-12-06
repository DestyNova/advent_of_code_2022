marker_size = 14

ARGF.each_line { |line|
  (0..line.size-marker_size).each { |i|
    if line[i..i+marker_size-1].chars.to_set.size == marker_size
      puts i+marker_size
      exit
    end
  }
}

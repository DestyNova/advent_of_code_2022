stacks = [] of Array(Char)

STDIN
  .gets_to_end
  .split("\n")
  .map { |line|

  if line.includes?("[")
    num_stacks = (line.size + 1) // 4

    (0..num_stacks-1).each { |i|
      if stacks.size <= i
        stacks << [] of Char
      end

      if line[4*i] == '['
        crate = line[4*i + 1]
        stacks[i] << crate
      end
    }
  elsif line.includes?("move")
    _,n,_,source,_,dest = line.split(" ")
    n,source,dest = [n,source,dest].map{|x| x.to_i}

    buf = [] of Char
    n.times {|i|
      crate = stacks[source-1].shift
      buf << crate
    }

    stacks[dest-1] = buf + stacks[dest-1]
  end
}
puts stacks.map {|s| s[0]}.join("")

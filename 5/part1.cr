stacks = [] of Array(Char)

STDIN
  .gets_to_end
  .split("\n")
  .map { |line|

  num_stacks = (line.size + 1) // 4

  if line.includes?("[")
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

    n.times {|i|
      crate = stacks[source-1].shift
      stacks[dest-1].unshift(crate)
    }
  end
}
puts stacks.map {|s| s[0]}.join("")

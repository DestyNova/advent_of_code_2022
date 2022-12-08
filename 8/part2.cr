g = STDIN
  .gets_to_end
  .strip
  .split("\n")
  .map {|row| row.chars.map {|t| t.to_i}}

s = g.size
max_dist = -1

(1..s-2).map { |j|
  (1..s-2).map { |i|
    dist = get_distance(g,i,j)
    if dist > max_dist
      max_dist = dist
    end
  }
}

puts max_dist

def get_distance(g,i,j)
  t = g[j][i]
  s = g.size

  # NOOOOOO
  clear = true
  left = (0..i-1).to_a.reverse.map { |x| g[j][x] }.take_while { |t2| if clear && t2 < t; true; elsif clear; clear=false; true end}
  clear = true
  right = (i+1..s-1).map { |x| g[j][x] }.take_while { |t2| if clear && t2 < t; true; elsif clear; clear=false; true end }
  clear = true
  top = (0..j-1).to_a.reverse.map { |y| g[y][i] }.take_while { |t2| if clear && t2 < t; true; elsif clear; clear=false; true end }
  clear = true
  bottom = (j+1..s-1).map { |y| g[y][i] }.take_while { |t2| if clear && t2 < t; true; elsif clear; clear=false; true end }

  [left,right,top,bottom].map {|side| side.size}.product
end


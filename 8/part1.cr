g = STDIN
  .gets_to_end
  .strip
  .split("\n")

s = g.size

puts (1..s-2).map { |j|
  (1..s-2).map { |i|
    if visible(g,i,j)
      1
    else
      0
    end
  }.sum
}.sum + s * 4 - 4

def visible(g,i,j)
  t = g[j][i]
  s = g.size
  (0..i-1).reduce(true) {|acc,x| acc && g[j][x] < t} ||
  (i+1..s-1).reduce(true) {|acc, x| acc && g[j][x] < t} ||
  (0..j-1).reduce(true) {|acc, y| acc && g[y][i] < t} ||
  (j+1..s-1).reduce(true) {|acc, y| acc && g[y][i] < t}
end


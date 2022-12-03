p File.read("input").strip.split("\n").map{|l|a=l.split(/./);a.partition.with_index{|c,i|i<a.length/2}}.map{|a,b|a&b}.map{|c|c[0].ord-((c[0]=~/[[:upper:]]/)?65:97)+1 if c[0]}.compact.sum

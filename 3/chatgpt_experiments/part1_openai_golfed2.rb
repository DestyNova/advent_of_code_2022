p File.read("input").strip.split("\n").map{|l|a=l.split(/./);a.partition.with_index{|c,i|i<a.length/2}}.map{|a,b|a&b}.flatten.map{|c|c.ord-((c=~/[[:upper:]]/)?65:97)+1}.sum

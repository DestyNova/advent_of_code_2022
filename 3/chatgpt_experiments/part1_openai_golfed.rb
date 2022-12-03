p File.read("sample.txt").strip.split("\n").map{|l|a=l.split(/./);a[0..a.length/2-1]&a[a.length/2..-1]}.flatten.map{|c|c.ord-((c=~/[[:upper:]]/)?65:97)+1}.sum

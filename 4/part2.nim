import sequtils,strutils

echo stdin.lines.toSeq.foldl((
   let
     ab = b.split(",").mapIt(it.split("-").map(parseInt))
     (lt, rt) = (ab[0], ab[1])
     (aLow, aHigh) = (lt[0], lt[1])
     (bLow, bHigh) = (rt[0], rt[1])
     aRange = (aLow..aHigh)
     bRange = (bLow..bHigh)

     isOverlap = bRange.contains(aLow) or
       bRange.contains(aHigh) or
       aRange.contains(bLow) or
       aRange.contains(bHigh)

   a + (if isOverlap: 1 else: 0)
), 0)

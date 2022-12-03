-- Parse the input
lines = {}
for line in io.lines("input") do
  lines[#lines + 1] = line
end

-- Initialize the priority sum to 0
priority_sum = 0

-- Iterate over the lines of the input
for i, line in ipairs(lines) do
  -- Initialize the count of characters in each compartment
  counts = {{}, {}}

  -- Iterate over the characters of the line
  for i, c in string.gmatch(line, ".") do
    -- Count the characters in each compartment
    counts[math.floor(i / (#line / 2)) + 1][c] = (counts[math.floor(i / (#line / 2)) + 1][c] or 0) + 1
  end

  -- Find the characters that appear in both compartments
  common_chars = {}
  for c, _ in pairs(counts[1]) do
    if counts[2][c] then
      common_chars[c] = true
    end
  end

  -- If there are no common characters, skip this line
  if next(common_chars) == nil then
    goto continue
  end

  -- Iterate over the common characters
  for c in pairs(common_chars) do
    -- Get the priority of the current common character
    priority = c:byte() - string.byte("a") + 1
    if c:match("%u") then
      priority = c:byte() - string.byte("A") + 27
    end

    --
    --
  end
end

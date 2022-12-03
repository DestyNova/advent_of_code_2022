# Parse the input
lines = File.read("input").strip.split("\n")

# Initialize the priority sum to 0
priority_sum = 0

# Iterate over the lines of the input
lines.each do |line|
  # Initialize the count of characters in each compartment
  counts = [{}, {}]
  
  # Iterate over the characters of the line
  line.each_char.with_index do |c, i|
    # Count the characters in each compartment
    counts[i / (line.length / 2)][c] = counts[i / (line.length / 2)].fetch(c, 0) + 1
  end
  
  # Find the characters that appear in both compartments
  common_chars = counts[0].keys & counts[1].keys
  
  # If there are no common characters, skip this line
  next if common_chars.empty?
  
  # Iterate over the common characters
  common_chars.each do |c|
    # Get the priority of the current common character
    priority = c.ord - "a".ord + 1
    priority = c.ord - "A".ord + 27 if c =~ /[[:upper:]]/
    
    # Add the priority to the priority sum
    priority_sum += priority
  end
end

# Print the final result
puts priority_sum

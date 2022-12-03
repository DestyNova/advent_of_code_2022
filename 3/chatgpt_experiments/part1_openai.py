# Parse the input
lines = open("input").read().strip().split("\n")

# Initialize the priority sum to 0
priority_sum = 0

# Iterate over the lines of the input
for line in lines:
  # Initialize the count of characters in each compartment
  counts = [{}, {}]
  
  # Iterate over the characters of the line
  for i, c in enumerate(line):
    # Count the characters in each compartment
    counts[i // (len(line) // 2)][c] = counts[i // (len(line) // 2)].get(c, 0) + 1
  
  # Find the characters that appear in both compartments
  common_chars = set(counts[0].keys()) & set(counts[1].keys())
  
  # If there are no common characters, skip this line
  if len(common_chars) == 0:
    continue
  
  # Get the priority of the first common character
  priority = ord(common_chars.pop()) - ord("a") + 1
  
  # Add the priority to the priority sum
  priority_sum += priority

# Print the final result
print(priority_sum)

puts STDIN
      .gets_to_end
      .split("\n\n")
      .map { |elf|
        elf
          .split
          .map { |cals| ("0" + cals).to_i }
          .sum
      }
      .sort { |a, b| b <=> a }[0..2]
      .sum

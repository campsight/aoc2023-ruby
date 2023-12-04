require 'set'

def parse_schematic(file_path)
  File.readlines(file_path).map { |line| line.chomp.chars }
end

def is_symbol?(char)
  char != '.' && !char.match?(/\d/)
end

def adjacent_to_symbol?(schematic, row, col)
  adjacent_positions = [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]
  adjacent_positions.any? do |dx, dy|
    x, y = row + dx, col + dy
    x.between?(0, schematic.length - 1) && y.between?(0, schematic[0].length - 1) && is_symbol?(schematic[x][y])
  end
end

def sum_of_part_numbers(schematic)
  sum = 0
  visited = Set.new

  schematic.each_with_index do |row, i|
    row.each_with_index do |char, j|
      next if visited.include?([i, j]) || !char.match?(/\d/)

      # Check if this digit or any part of the number it belongs to is adjacent to a symbol
      if adjacent_to_symbol?(schematic, i, j)
        # Collect the whole number
        number_str = ""
        k = j
        while k >= 0 && schematic[i][k].match?(/\d/)
          number_str.prepend(schematic[i][k])
          visited.add([i, k])
          k -= 1
        end

        k = j + 1
        while k < row.length && schematic[i][k].match?(/\d/)
          number_str << schematic[i][k]
          visited.add([i, k])
          k += 1
        end

        puts number_str
        sum += number_str.to_i
      end
    end
  end

  sum
end

# Replace 'path_to_your_input_file.txt' with the actual path to your input file
file_path = 'data/day3_nele.txt'

### Part 2 ###
def is_gear?(schematic, row, col)
  schematic[row][col] == '*'
end

def calculate_gear_ratio(schematic, row, col)
  adjacent_positions = [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]
  part_numbers = []
  visited = Set.new

  adjacent_positions.each do |dx, dy|
    x, y = row + dx, col + dy
    next unless x.between?(0, schematic.length - 1) && y.between?(0, schematic[0].length - 1)
    next if visited.include?([x, y])

    if schematic[x][y].match?(/\d/)
      number_str, number_pos = "", []
      # Collect the full number
      while y >= 0 && schematic[x][y].match?(/\d/)
        number_str.prepend(schematic[x][y])
        number_pos << [x, y]
        y -= 1
      end

      y = col + dy + 1
      while y < schematic[0].length && schematic[x][y].match?(/\d/)
        number_str << schematic[x][y]
        number_pos << [x, y]
        y += 1
      end

      unless number_str.empty?
        part_numbers << number_str.to_i
        number_pos.each { |pos| visited.add(pos) }
      end
    end
  end

  part_numbers.length == 2 ? part_numbers.inject(:*) : 0
end


def sum_of_gear_ratios(schematic)
  gear_ratios_sum = 0

  schematic.each_with_index do |row, i|
    row.each_with_index do |char, j|
      if is_gear?(schematic, i, j)
        gear_ratios_sum += calculate_gear_ratio(schematic, i, j)
      end
    end
  end

  gear_ratios_sum
end

# Continue using the previous script for sum_of_part_numbers and other methods

# Combine the results
schematic = parse_schematic(file_path)
total_part_number_sum = sum_of_part_numbers(schematic)
total_gear_ratios_sum = sum_of_gear_ratios(schematic)
puts "The sum of all part numbers is #{total_part_number_sum}"
puts "The sum of all gear ratios is #{total_gear_ratios_sum}"


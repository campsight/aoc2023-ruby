def read_grid(file_path)
  grid = []

  File.open(file_path, 'r') do |file|
    file.each_line do |line|
      grid << line.strip.split('')
    end
  end

  grid
end

def number_galaxies(grid)
  galaxy_number = 1
  numbered_grid = grid.map do |row|
    row.map do |cell|
      if cell == '#'
        galaxy_number.to_s.tap { galaxy_number += 1 }
      else
        cell
      end
    end
  end

  [numbered_grid, galaxy_number - 1]
end


def find_empty_rows_and_columns(grid)
  empty_rows = []
  empty_columns = []

  # Check for empty rows
  grid.each_with_index do |row, index|
    empty_rows << index if row.none?('#')
  end

  # Check for empty columns
  if grid.any?
    (0...grid.first.size).each do |col_index|
      empty_columns << col_index if grid.all? { |row| row[col_index] == '.' }
    end
  end


  [empty_rows, empty_columns]
end


def manhattan_distance_with_expansion(point1, point2, empty_rows, empty_columns, multiplier = 1)
  x1, y1 = point1
  x2, y2 = point2

  row_distance = (y2 - y1).abs
  col_distance = (x2 - x1).abs

  # Count the number of empty rows and columns between the two points
  extra_rows = empty_rows.count { |row| row.between?([y1, y2].min, [y1, y2].max) }
  extra_cols = empty_columns.count { |col| col.between?([x1, x2].min, [x1, x2].max) }

  # Add the extra distances due to empty rows and columns
  row_distance + extra_rows * multiplier + col_distance + extra_cols * multiplier
end


def sum_of_shortest_paths(grid, num_galaxies, empty_rows, empty_columns, nb_expansions = 1)
  # Find coordinates of all galaxies
  galaxy_positions = {}
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      galaxy_positions[cell] = [x, y] if cell.match?(/\d+/)  # Check if the cell contains a galaxy number
    end
  end

  # Calculate sum of shortest paths for all pairs
  sum = 0
  (1..num_galaxies).each do |i|
    (i + 1..num_galaxies).each do |j|
      start = galaxy_positions[i.to_s]
      goal = galaxy_positions[j.to_s]
      sum += manhattan_distance_with_expansion(start, goal, empty_rows, empty_columns, nb_expansions)
    end
  end

  sum
end


def sum_shortest_paths(file_path, nb_expensions = 1)
  original_grid = read_grid(file_path)  # Assume read_grid is implemented
  empty_rows, empty_columns = find_empty_rows_and_columns(original_grid)
  numbered_grid, num_galaxies = number_galaxies(original_grid)
  sum_of_shortest_paths(numbered_grid, num_galaxies, empty_rows, empty_columns, nb_expensions)
end

file_path = 'data/day11.txt'  # Replace with your input file path
total_path_length = sum_shortest_paths(file_path)
puts "Total sum of shortest paths between all galaxy pairs: #{total_path_length}"
total_path_length = sum_shortest_paths(file_path, 1000000-1)
puts "Total sum of shortest paths between all galaxy pairs (part 2): #{total_path_length}"


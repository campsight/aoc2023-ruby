# Reads the map from a file and returns it as a 2D array.
def read_map(filename)
  File.readlines(filename).map { |line| line.chomp.chars }
end

# Prints the map with an optional path.
def print_map(map, path = [])
  map.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if path.include?([x, y])
        print 'O'
      else
        print cell
      end
    end
    puts
  end
end

# Returns possible moves from the current position.
def possible_moves(map, x, y, prev_x, prev_y)
  moves = []
  moves << [x, y - 1] unless y - 1 == prev_y # Up
  moves << [x + 1, y] unless x + 1 == prev_x # Right
  moves << [x, y + 1] unless y + 1 == prev_y # Down
  moves << [x - 1, y] unless x - 1 == prev_x # Left
  moves.select { |nx, ny| valid_position?(map, nx, ny) }
end

# Checks if the position is within the map and not an obstacle.
def valid_position?(map, x, y)
  0 <= y && y < map.size && 0 <= x && x < map[0].size && map[y][x] != '#'
end

# Finds all paths from the current position to the goal.
def find_paths(map, x, y, prev_x, prev_y, path = [], slippery_hills = true)
  # Base case: reached the bottom row.
  if y == map.size - 1
    return [path + [[x, y]]]
  end

  paths = []
  # Determine next moves based on the current tile and slope direction.

  if slippery_hills
    next_moves = map[y][x] == '.' ? possible_moves(map, x, y, prev_x, prev_y) : [move(x, y, map[y][x])]
  else
    next_moves = possible_moves(map, x, y, prev_x, prev_y)
  end

  next_moves.each do |next_x, next_y|
    if valid_position?(map, next_x, next_y) && !path.include?([next_x, next_y])
      new_path = find_paths(map, next_x, next_y, x, y, path + [[x, y]], slippery_hills)
      paths.concat(new_path) unless new_path.empty?
    end
  end

  paths
end

# Moves according to the slope direction.
def move(x, y, direction)
  case direction
  when '^' then [x, y - 1]
  when '>' then [x + 1, y]
  when 'v' then [x, y + 1]
  when '<' then [x - 1, y]
  else [x, y]
  end
end

# Main function to solve the puzzle.
def longest_hike(filename, slippery_hills = true)
  map = read_map(filename)

  # Find the entry point (the single '.' in the first line).
  entry_x = map[0].index('.')
  entry_y = 0

  # Ensure the entry point is found before proceeding.
  unless entry_x
    puts "No entry point found in the map."
    return
  end

  # Find all paths from the entry point to the bottom of the map.
  all_paths = find_paths(map, entry_x, entry_y, -1, -1, [], slippery_hills)

  longest_path = all_paths.max_by(&:length)

  puts "Longest Path Length: #{longest_path.length - 1}"
  #print_map(map, longest_path)
  #all_paths.each { |p| puts "Path of length #{p.length - 1}: #{p.inspect}" }
end

# Run the program with the provided map file.
longest_hike('data/day23_test.txt')

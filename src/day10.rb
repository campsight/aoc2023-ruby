def read_grid(file_path)
  File.readlines(file_path).map(&:chomp).map(&:chars)
end

def find_starting_position(grid)
  grid.each_with_index do |row, y|
    x = row.index('S')
    return [x, y] if x
  end
end

def dfs(grid, x, y, path, visited, longest_loop)
  directions = {'|' => [[0, -1], [0, 1]], '-' => [[-1, 0], [1, 0]],
                'L' => [[0, -1], [1, 0]], 'J' => [[0, -1], [-1, 0]],
                '7' => [[0, 1], [-1, 0]], 'F' => [[0, 1], [1, 0]],
                'S' => [[0, -1], [0, 1], [-1, 0], [1, 0]]}

  # Skip if out of bounds or at a ground tile
  return if (0...grid.length).cover?(y) == false || (0...grid[0].length).cover?(x) == false || grid[y][x] == '.'

  # Check if we returned to the start 'S'
  if grid[y][x] == 'S' && path.any?
    loop_length = path.length
    longest_loop[0] = path.dup if loop_length > longest_loop[0].length
    return
  end

  # Skip if the node is already visited in the current path
  return if visited.include?([x, y])

  # Mark the node as visited and add it to the path
  visited.add([x, y])
  path.push([x, y])

  # Explore adjacent nodes
  directions[grid[y][x]].each do |dx, dy|
    dfs(grid, x + dx, y + dy, path, visited, longest_loop)
  end

  # Backtrack: remove the node from the path and visited set
  path.pop
  visited.delete([x, y])
end

def iterative_dfs(grid, start_x, start_y)
  stack = [[start_x, start_y, []]]  # [x, y, path]
  longest_loop = []
  directions = {'|' => [[0, -1], [0, 1]], '-' => [[-1, 0], [1, 0]],
                'L' => [[0, -1], [1, 0]], 'J' => [[0, -1], [-1, 0]],
                '7' => [[0, 1], [-1, 0]], 'F' => [[0, 1], [1, 0]],
                'S' => [[0, -1], [0, 1], [-1, 0], [1, 0]]}

  while !stack.empty?
    x, y, path = stack.pop

    # Skip invalid or ground tiles
    next if (0...grid.length).cover?(y) == false || (0...grid[0].length).cover?(x) == false || grid[y][x] == '.'

    # Forming a new path including the current tile
    new_path = path + [[x, y]]

    # Detecting a loop when returning to 'S'
    if grid[y][x] == 'S' && new_path.size > 1 && new_path.first == [start_x, start_y]
      loop_length = new_path.size - 1
      if loop_length > longest_loop.size
        longest_loop = new_path[0...-1] # Exclude the last 'S' to avoid duplication
        puts "Found loop returning to 'S', Length: #{loop_length}" # Debug statement
      end
      next
    end

    # Skip if this tile is already in the current path (except for 'S')
    next if path.include?([x, y])

    # Exploring adjacent nodes
    directions[grid[y][x]].each do |dx, dy|
      next_x, next_y = x + dx, y + dy
      stack.push([next_x, next_y, new_path])
    end
  end

  longest_loop
end


def longest_loop_distance(grid, start_x, start_y)
  longest_loop = [Set.new]
  visited = Set.new
  dfs(grid, start_x, start_y, [], visited, longest_loop)
  longest_loop[0].size / 2
end

def bfs_shortest_distance(grid, start_x, start_y, loop_path)
  queue = [[start_x, start_y, 0]]  # [x, y, distance]
  visited = { [start_x, start_y] => 0 }
  directions = {'|' => [[0, -1], [0, 1]], '-' => [[-1, 0], [1, 0]],
                'L' => [[0, -1], [1, 0]], 'J' => [[0, -1], [-1, 0]],
                '7' => [[0, 1], [-1, 0]], 'F' => [[0, 1], [1, 0]],
                'S' => [[0, -1], [0, 1], [-1, 0], [1, 0]]}

  while !queue.empty?
    x, y, distance = queue.shift
    next unless loop_path.include?([x, y])

    directions[grid[y][x]].each do |dx, dy|
      next_x, next_y = x + dx, y + dy
      next if visited.include?([next_x, next_y])

      visited[[next_x, next_y]] = distance + 1
      queue << [next_x, next_y, distance + 1]
    end

  end

  visited
end

def farthest_point_distance(grid, start_x, start_y, loop_path)
  distances = bfs_shortest_distance(grid, start_x, start_y, loop_path)
  distances.values.max
end

def max_distance_in_loop(file_path)
  grid = read_grid(file_path)
  start_x, start_y = find_starting_position(grid)
  longest_loop = [[]]
  visited = Set.new
  dfs(grid, start_x, start_y, [], visited, longest_loop)
  farthest_point_distance(grid, start_x, start_y, longest_loop[0].to_a)
end

def max_distance_in_loop_i(file_path)
  grid = read_grid(file_path)
  start_x, start_y = find_starting_position(grid)
  longest_loop = iterative_dfs(grid, start_x, start_y)
  # Calculate the farthest point distance in the loop
  loop_length = longest_loop.size
  loop_length / 2  # Farthest distance
end

file_path = 'data/day10.txt'  # Replace with your input file path
#distance = max_distance_in_loop_i(file_path)
#puts "Farthest distance from the start in the longest loop: #{distance}"


#### PART 2 ############################
# Find tiles enclosed in loop

def iterative_dfs2(grid, start_x, start_y)
  stack = [[start_x, start_y, []]]  # [x, y, path]
  longest_loop = []
  longest_path = []
  directions = {'|' => [[0, -1], [0, 1]], '-' => [[-1, 0], [1, 0]],
                'L' => [[0, -1], [1, 0]], 'J' => [[0, -1], [-1, 0]],
                '7' => [[0, 1], [-1, 0]], 'F' => [[0, 1], [1, 0]],
                'S' => [[0, -1], [0, 1], [-1, 0], [1, 0]]}

  while !stack.empty?
    x, y, path = stack.pop

    # Skip invalid or ground tiles
    next if (0...grid.length).cover?(y) == false || (0...grid[0].length).cover?(x) == false || grid[y][x] == '.'

    # Forming a new path including the current tile
    new_path = path + [[x, y]]

    # Detecting a loop when returning to 'S'
    if grid[y][x] == 'S' && new_path.size > 1 && new_path.first == [start_x, start_y]
      loop_length = new_path.size - 1
      if loop_length > longest_loop.size
        longest_loop = new_path[0...-1] # Exclude the last 'S' to avoid duplication
        puts "Found loop returning to 'S', Length: #{loop_length}" # Debug statement
      end
      next
    end

    # Skip if this tile is already in the current path (except for 'S')
    next if path.include?([x, y])

    # Exploring adjacent nodes
    directions[grid[y][x]].each do |dx, dy|
      next_x, next_y = x + dx, y + dy
      stack.push([next_x, next_y, new_path])
    end
  end

  longest_loop
end

def count_tiles_inside_loop(grid, longest_loop)
  total_inside = 0
  height = grid.length

  grid.each_with_index do |row, y|
    loop_piece_counter = 0
    debug_row = ""

    row.each_with_index do |cell, x|
      if longest_loop.include?([x, y])
        current_index = longest_loop.index([x, y])
        below_index = current_index && y < height - 1 ? longest_loop.index([x, y+1]) : nil
        adjacent_below = below_index && (below_index == current_index + 1 || below_index == current_index - 1)
        if adjacent_below || (current_index == 0 && below_index && below_index == longest_loop.length - 1)
          loop_piece_counter += 1
          debug_row += cell
        else
          debug_row += 'X'  # Retain the original loop cell for visualization
        end
      else
        if loop_piece_counter.odd?
          total_inside += 1
          debug_row += "I"  # Mark as inside
        else
          debug_row += "O"  # Mark as outside
        end
      end
    end

    # Debug: Print the row with I/O markings
    puts debug_row
  end

  total_inside
end


def total_enclosed_tiles(file_path)
  grid = read_grid(file_path)
  start_x, start_y = find_starting_position(grid)
  longest_loop = iterative_dfs2(grid, start_x, start_y)
  puts "Farthest distance from the start in the longest loop: #{longest_loop.length / 2}"
  count_tiles_inside_loop(grid, longest_loop)
end

enclosed_tiles = total_enclosed_tiles(file_path)
puts "Number of tiles enclosed by the loop: #{enclosed_tiles}"

require 'set'

# Parse the grid from the file
def parse_grid(file_path)
  File.readlines(file_path).map { |line| line.chomp.chars.map(&:to_i) }
end

# A* search algorithm
def a_star_search(grid)
  start = [0, 0, 'right', 0]  # [row, col, direction, consecutive_moves]
  goal = [grid.length - 1, grid[0].length - 1]
  open_set = [start]
  came_from = {}
  g_score = Hash.new(Float::INFINITY)
  g_score[start] = 0
  f_score = Hash.new(Float::INFINITY)
  f_score[start] = heuristic(start, goal)

  until open_set.empty?
    current = open_set.min_by { |node| f_score[node] }
    return reconstruct_path(came_from, current) if current[0..1] == goal

    open_set.delete(current)
    neighbors(current, grid).each do |neighbor|
      tentative_g_score = g_score[current] + grid[neighbor[0]][neighbor[1]]
      if tentative_g_score < g_score[neighbor]
        came_from[neighbor] = current
        g_score[neighbor] = tentative_g_score
        f_score[neighbor] = tentative_g_score + heuristic(neighbor, goal)
        open_set << neighbor unless open_set.include?(neighbor)
      end
    end
  end

  nil  # Path not found
end

# Heuristic function (Manhattan distance)
def heuristic(node, goal)
  (node[0] - goal[0]).abs + (node[1] - goal[1]).abs
end

# Reconstruct the path from the came_from map
def reconstruct_path(came_from, current)
  total_path = [current]
  while came_from.include?(current)
    current = came_from[current]
    total_path.prepend(current)
  end
  total_path
end

# Neighbors function needs to be implemented
# Directions and their corresponding movement offsets
DIRECTIONS = {
  'right' => [0, 1],
  'left' => [0, -1],
  'up' => [-1, 0],
  'down' => [1, 0]
}

# Generates the possible neighbors for a given node
def neighbors(node, grid)
  row, col, direction, consecutive_moves = node
  possible_neighbors = []

  # Function to add a neighbor if it's a valid position
  add_neighbor = lambda do |r, c, dir, moves|
    if valid_position?(r, c, grid)
      possible_neighbors << [r, c, dir, moves]
    end
  end

  # Continue in the same direction if not exceeding three moves
  if consecutive_moves < 3
    dr, dc = DIRECTIONS[direction]
    add_neighbor.call(row + dr, col + dc, direction, consecutive_moves + 1)
  end

  # Turn left and right
  left_dir, right_dir = turn_directions(direction)
  add_neighbor.call(row + DIRECTIONS[left_dir][0], col + DIRECTIONS[left_dir][1], left_dir, 1)
  add_neighbor.call(row + DIRECTIONS[right_dir][0], col + DIRECTIONS[right_dir][1], right_dir, 1)

  possible_neighbors
end

# Check if the position is valid (within grid bounds and not blocked)
def valid_position?(row, col, grid)
  row.between?(0, grid.length - 1) && col.between?(0, grid[0].length - 1)
end

# Determine left and right turn directions based on the current direction
def turn_directions(direction)
  case direction
  when 'right'
    ['up', 'down']
  when 'left'
    ['down', 'up']
  when 'up'
    ['left', 'right']
  when 'down'
    ['right', 'left']
  end
end


grid = parse_grid('data/day17.txt')
path = a_star_search(grid)
# Calculate the heat loss of the path
heat_loss = path.sum { |node| grid[node[0]][node[1]] }
puts "Least heat loss: #{heat_loss}"

def read_map(filename)
  File.readlines(filename).map(&:chomp)
end

# Checks if the position is within the map and not an obstacle.
def valid_position?(map, x, y)
  0 <= y && y < map.size && 0 <= x && x < map[0].size && map[y][x] != '#'
end

def is_crossroad(map, x, y)
  return false if map[y][x] == '#'
  adjacent = [[1, 0], [-1, 0], [0, 1], [0, -1]]
  adjacent.count { |dx, dy| valid_position?(map, x+dx, y+dy) && map[y + dy][x + dx] != '#' } > 2
end

def possible_moves(map, x, y, prev_x, prev_y)
  moves = []
  moves << [x, y - 1] unless (not valid_position?(map, x, y-1)) || y - 1 == prev_y || map[y - 1][x] == '#'
  moves << [x + 1, y] unless (not valid_position?(map, x+1, y)) || x + 1 == prev_x || map[y][x + 1] == '#'
  moves << [x, y + 1] unless (not valid_position?(map, x, y+1)) || y + 1 == prev_y || map[y + 1][x] == '#'
  moves << [x - 1, y] unless (not valid_position?(map, x-1, y)) || x - 1 == prev_x || map[y][x - 1] == '#'
  moves
end

def find_paths_from_crossroad(map, x, y, entry, exit)
  paths = {}
  explore_path(map, x, y, -1, -1, paths, [], entry, exit)
  paths
end

def explore_path(map, x, y, prev_x, prev_y, paths, current_path, entry, exit)
  moves = possible_moves(map, x, y, prev_x, prev_y)

  moves.each do |next_x, next_y|
    if is_crossroad(map, next_x, next_y) || exit == [next_y, next_x]
      # If the next move is a crossroad and not already in the path, save the path.
      paths[[next_y, next_x]] = current_path.length + 1
    elsif !current_path.include?([next_y, next_x])
      # If the next move is valid and not already in the path, continue exploring.
      explore_path(map, next_x, next_y, x, y, paths, current_path + [[y, x]], entry, exit)
    end
  end
end

def build_graph(map, entry, exit)
  height = map.size
  width = map.first.size
  graph = {}

  (0...height).each do |y|
    (0...width).each do |x|
      if is_crossroad(map, x, y) || entry == [y, x]
        graph[[y, x]] = find_paths_from_crossroad(map, x, y, entry, exit)
      end
    end
  end
  puts graph
  graph
end

def print_graph(graph)
  graph.each do |crossroad, paths|
    puts "Crossroad at #{crossroad}:"
    paths.each do |destination, weight|
      puts "  leads to #{destination} with a path length of #{weight}"
    end
  end
end

def find_longest_path(graph, start, goal)
  longest_path = { length: 0, path: [] }
  visited = {}

  dfs(graph, start, goal, visited, [], 0, longest_path)

  longest_path
end

def dfs(graph, current, goal, visited, path, length, longest_path)
  # Mark the current node as visited and add it to the path
  visited[current] = true
  path << current

  # If the current node is the goal and the path is longer than the longest found so far
  if current == goal && length > longest_path[:length]
    longest_path[:length] = length
    longest_path[:path] = path.dup
  end

  # Explore adjacent nodes
  graph[current]&.each do |adjacent, weight|
    unless visited[adjacent]
      dfs(graph, adjacent, goal, visited, path, length + weight, longest_path)
    end
  end

  # Backtrack: unmark the current node as visited and remove it from the path
  visited[current] = false
  path.pop
end


map = read_map('data/day23.txt')
entry = [0, map[0].index('.')]
exit = [map.size - 1, map[(map.size - 1)].index('.')]
puts "Entry point = #{entry}."
puts "Exit point = #{exit}."
graph = build_graph(map, entry, exit)
print_graph(graph)
longest_path_info = find_longest_path(graph, entry, exit)
puts "Longest path found: #{longest_path_info[:length]}"

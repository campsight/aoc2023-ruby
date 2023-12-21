def read_map(file_name)
  map = []
  File.readlines(file_name).each do |line|
    map << line.strip.split('')
  end
  map
end

def find_start(map)
  map.each_with_index do |row, y|
    x = row.index('S')
    return [x, y] if x
  end
end

def in_bounds?(x, y, map)
  y >= 0 && y < map.size && x >= 0 && x < map[0].size
end

def bfs(map, start_x, start_y, steps)
  positions = Set.new
  positions.add([start_x, start_y])

  steps.times do
    next_positions = Set.new

    positions.each do |x, y|
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dx, dy|
        nx, ny = x + dx, y + dy

        if in_bounds?(nx, ny, map) && map[ny][nx] != '#'
          next_positions.add([nx, ny])
        end
      end
    end

    positions = next_positions
  end

  positions.count
end

def solve_puzzle(file_name)
  map = read_map(file_name)
  start_x, start_y = find_start(map)
  bfs(map, start_x, start_y, 64)
end

# Use the solve_puzzle method to find the number of plots
puts solve_puzzle("data/day21.txt")

require 'set'

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

def get_char_at(map, x, y)
  map_y_size = map.size
  map_x_size = map[0].size

  effective_y = (y % map_y_size + map_y_size) % map_y_size
  effective_x = (x % map_x_size + map_x_size) % map_x_size

  map[effective_y][effective_x]
end


def bfs(map, start_x, start_y, steps)
  positions = Set.new
  positions.add([start_x, start_y])
  prev_len = 0
  y_values = []
  width = map.length

  steps.times do |step|
    next_positions = Set.new

    positions.each do |x, y|
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dx, dy|
        nx, ny = x + dx, y + dy

        if get_char_at(map, nx, ny) != '#'
          next_positions.add([nx, ny])
        end
      end
    end

    if step % width == steps % width
      puts "#{step}, #{positions.count}, #{positions.count - prev_len}, #{step / width}"
      prev_len = positions.count
      y_values << prev_len
    end

    break if y_values.length == 3

    positions = next_positions
  end

  y_values
end

# credits for this formula go to https://www.reddit.com/user/charr3/
def polynomial_fit(n, y_values)
  b0 = y_values[0]
  b1 = y_values[1] - y_values[0]
  b2 = y_values[2] - y_values[1]
  b0 + b1 * n + (n * (n - 1) / 2) * (b2 - b1)
end

def solve_puzzle(file_name, steps)
  map = read_map(file_name)
  start_x, start_y = find_start(map)
  y_values = bfs(map, start_x, start_y, steps)
  n = steps / map.length
  polynomial_fit(n, y_values)
end

puts solve_puzzle("data/day21.txt", 26501365)

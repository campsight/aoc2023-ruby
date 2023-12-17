def process_contraption(grid)
  energized = Array.new(grid.length) { Array.new(grid[0].length) { Set.new } }
  simulate_beam(grid, energized, 0, 0, 'right')
  energized.flatten.count { |directions| !directions.empty? }
end

def simulate_beam(grid, energized, x, y, direction)
  while x >= 0 && x < grid.length && y >= 0 && y < grid[0].length
    # Stop if the beam has already passed through here in this direction
    break if energized[x][y].include?(direction)

    energized[x][y].add(direction)
    case grid[x][y]
    when '.'
      x, y = move_forward(x, y, direction)
    when '/'
      direction = reflect_direction(direction, '/')
      x, y = move_forward(x, y, direction)
    when '\\'
      direction = reflect_direction(direction, '\\')
      x, y = move_forward(x, y, direction)
    when '|', '-'
      # Handle beam splitting
      if (direction == 'right' || direction == 'left') && grid[x][y] == '|'
        simulate_beam(grid, energized, x, y, 'up')
        simulate_beam(grid, energized, x, y, 'down')
        break
      elsif (direction == 'up' || direction == 'down') && grid[x][y] == '-'
        simulate_beam(grid, energized, x, y, 'left')
        simulate_beam(grid, energized, x, y, 'right')
        break
      else
        x, y = move_forward(x, y, direction)
      end
    else
      break
    end
  end
end

def move_forward(x, y, direction)
  case direction
  when 'right'
    [x, y + 1]
  when 'left'
    [x, y - 1]
  when 'up'
    [x - 1, y]
  when 'down'
    [x + 1, y]
  end
end

def reflect_direction(current_direction, mirror_type)
  case [current_direction, mirror_type]
  when ['right', '/'], ['left', '\\']
    'up'
  when ['right', '\\'], ['left', '/']
    'down'
  when ['up', '/'], ['down', '\\']
    'right'
  when ['up', '\\'], ['down', '/']
    'left'
  else
    current_direction
  end
end

#######@### PART 2 ##################

def find_best_configuration(grid)
  max_energized = 0
  best_start = nil
  best_direction = nil

  # Top and bottom edges
  [0, grid.length - 1].each do |x|
    direction = x == 0 ? 'down' : 'up'
    (0...grid[0].length).each do |y|
      energized = Array.new(grid.length) { Array.new(grid[0].length) { Set.new } }
      simulate_beam(grid, energized, x, y, direction)
      energized_count = energized.flatten.count { |dirs| !dirs.empty? }
      if energized_count > max_energized
        max_energized = energized_count
        best_start = [x, y]
        best_direction = direction
      end
      # puts "Energized tile: #{energized_count}, Starting at: #{x}, Direction: #{y}"
    end
  end

  # Left and right edges
  [0, grid[0].length - 1].each do |y|
    direction = y == 0 ? 'right' : 'left'
    (0...grid.length).each do |x|
      energized = Array.new(grid.length) { Array.new(grid[0].length) { Set.new } }
      simulate_beam(grid, energized, x, y, direction)
      energized_count = energized.flatten.count { |dirs| !dirs.empty? }
      if energized_count > max_energized
        max_energized = energized_count
        best_start = [x, y]
        best_direction = direction
      end
      # puts "Energized tile: #{energized_count}, Starting at: #{x}, Direction: #{y}"
    end
  end

  [max_energized, best_start, best_direction]
end

t1 = Time.now
grid = File.readlines('data/day16.txt').map(&:chomp).map(&:chars)
total_energized = process_contraption(grid)
t2 = Time.now
delta_p1 = t2 - t1
puts "Total energized tiles: #{total_energized} in #{delta_p1} s"

max_energized, best_start, best_direction = find_best_configuration(grid)
t3 = Time.now
delta_p2 = t3 - t2
puts "Maximum energized tiles: #{max_energized}, Starting at: #{best_start}, Direction: #{best_direction} (p2 took #{delta_p2} s)"

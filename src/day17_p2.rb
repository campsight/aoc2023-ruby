require 'set'
require 'pqueue'

def search_path(n_start, n_end, min_straight, max_straight, grid)
  # Define a new priority queue based on the accumulated heat
  queue = PQueue.new { |a, b| a[0] < b[0] }
  # Initialize the queue with the n_start point and 0 heat.
  queue.push([0, *n_start, 0, 0])
  # Don't overdo things: keep track of the paths (start, end) we have already seen
  seen = Set.new

  while !queue.empty?
    heat, x, y, px, py = queue.pop
    # priority queue pops lowest heat; if that is the end point, we've got our solution
    return heat if [x, y] == n_end
    # Don't overdo things: seen is seen
    next if seen.include?([x, y, px, py])

    # Not seen yet, being treated now => add to seen
    seen.add([x, y, px, py])

    # Only look at turns here. Turns are added only between the min_straight and max_straight points!
    [[1, 0], [0, 1], [-1, 0], [0, -1]].reject { |dx, dy| [dx, dy] == [px, py] || [dx, dy] == [-px, -py] }.each do |dx, dy|
      new_x, new_y, new_heat = x, y, heat

      # between min and max_straight: add the points in that direction
      (1..max_straight).each do |i|
        new_x += dx
        new_y += dy
        next unless grid.include?([new_x, new_y])  # skip if point outside grid
        new_heat += grid[[new_x, new_y]]
        queue.push([new_heat, new_x, new_y, dx, dy]) if i >= min_straight
      end
    end
  end

  nil
end

# Reading the grid from the file and converting it into a hash
def parse_grid(file_path)
  grid = {}
  File.open(file_path, 'r').each_with_index do |row, i|
    row.strip.chars.each_with_index do |cell, j|
      grid[[i, j]] = cell.to_i
    end
  end
  grid
end

grid = parse_grid('data/day17.txt')
puts search_path([0, 0], grid.keys.max, 1, 3, grid)
puts search_path([0, 0], grid.keys.max, 4, 10, grid)

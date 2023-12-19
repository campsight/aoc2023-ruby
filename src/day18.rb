def parse_dig_plan(file_path)
  plan = []
  File.foreach(file_path) do |line|
    direction, distance, _color = line.strip.split
    plan << [direction, distance.to_i]
  end
  plan
end

def execute_dig_plan(plan)
  x, y = 0, 0
  lagoon = Hash.new('.')
  plan.each do |direction, distance|
    case direction
    when 'U'
      (1..distance).each { |dy| lagoon[[x, y - dy]] = '#' }
      y -= distance
    when 'D'
      (1..distance).each { |dy| lagoon[[x, y + dy]] = '#' }
      y += distance
    when 'L'
      (1..distance).each { |dx| lagoon[[x - dx, y]] = '#' }
      x -= distance
    when 'R'
      (1..distance).each { |dx| lagoon[[x + dx, y]] = '#' }
      x += distance
    end
    # Debug statement
    # puts "After #{direction} #{distance}: #{lagoon.values.count('#')} cubes dug out"
  end
  lagoon
end

def calculate_lava_capacity(lagoon)
  lagoon.values.count('#')
end

def count_tiles_inside_loop(grid)
  total_inside = 0
  height = grid.length

  grid.each_with_index do |row, y|
    loop_piece_counter = 0
    debug_row = ""

    row.each_with_index do |cell, x|
      if cell == '#'
        # above_index = y > 0 ? grid[x][y-1] : nil
        below_index = y < height - 1 ? grid[y+1][x] : nil
        # if (above_index && above_index == '#') || (below_index && below_index == '#')
        if below_index && below_index == '#'
          loop_piece_counter += 1
          debug_row += cell
        else
          debug_row += '#'  # Retain the original loop cell for visualization
        end
      else
        if loop_piece_counter.odd?
          total_inside += 1
          debug_row += "I"  # Mark as inside
        else
          debug_row += "."  # Mark as outside
        end
      end
    end

    # Debug: Print the row with I/O markings
    # puts debug_row
  end

  total_inside
end

def create_grid_from_lagoon(lagoon)
  min_x, max_x = lagoon.keys.map { |x, _y| x }.minmax
  min_y, max_y = lagoon.keys.map { |_, y| y }.minmax

  grid = Array.new(max_y - min_y + 1) { Array.new(max_x - min_x + 1, '.') }

  lagoon.each do |(x, y), char|
    grid[y - min_y][x - min_x] = char
  end

  grid
end

def print_lagoon(lagoon)
  min_x, max_x = lagoon.keys.map { |x, _y| x }.minmax
  min_y, max_y = lagoon.keys.map { |_, y| y }.minmax

  (min_y..max_y).each do |y|
    row = (min_x..max_x).map { |x| lagoon.fetch([x, y], '.') }.join
    puts row
  end
end

# Main execution
plan = parse_dig_plan('data/day18.txt')
lagoon = execute_dig_plan(plan)
# print_lagoon(lagoon) # Debug statement to print the trench
nb_inside = count_tiles_inside_loop(create_grid_from_lagoon(lagoon))
lava_capacity = calculate_lava_capacity(lagoon) + nb_inside
puts "Total lava capacity: #{lava_capacity} cubic meters"


### Part 2 ###

def convert_hex_to_instruction(hex_code)
  distance = hex_code[2..6].to_i(16) # Convert the first five hex digits to an integer
  direction_code = hex_code[-2].to_i(16) # Last hex digit as an integer

  direction_map = { 0 => 'R', 1 => 'D', 2 => 'L', 3 => 'U' }
  direction = direction_map[direction_code]

  # puts "#{direction} #{distance}"

  [direction, distance]
end

def parse_dig_plan2(file_path)
  current_position = [0, 0]
  vertices = [[0,0]]
  total_distance = 0
  File.foreach(file_path) do |line|
    _, _, color = line.strip.split
    direction, distance = convert_hex_to_instruction(color)
    start_position = current_position.dup
    case direction
    when 'U'
      current_position[1] -= distance
    when 'D'
      current_position[1] += distance
    when 'L'
      current_position[0] -= distance
    when 'R'
      current_position[0] += distance
    end
    total_distance += distance
    next_x, next_y = current_position.dup
    vertices << [next_y, next_x]
  end

  [total_distance, vertices]
end


def count_filled_positions(vertices)
  sum = 0

  # vertices.each_with_index do |(y1, x1), index|
  #  y2, x2 = vertices[(index + 1) % vertices.length]
  #  sum += (x1 * y2) - (y1 * x2)
  #end

  vertices.each_cons(2) do |(y1, x1), (y2, x2)|
    sum += (x1 * y2) - (y1 * x2)
  end

  inner_area = (sum.abs / 2 + 1).to_i
  inner_area
end

edge_distance, vertices = parse_dig_plan2('data/day18.txt')
# adjust_vertical_segments(segments)
# puts vertices
lava_capacity = (count_filled_positions(vertices) + edge_distance * 0.5).to_i
puts "Total lava capacity: #{lava_capacity} cubic meters"

def read_and_parse_input(file_path)
  #File.readlines(file_path).map(&:chomp).map(&:chars)
  File.readlines(file_path).map(&:chomp)
end

def tilt_platform_north(platform)
  num_cols = platform.first.length

  (0...num_cols).each do |col|
    column = platform.map { |row| row[col] }
    # Move rounded rocks up in the column
    updated_column = move_rocks_up(column)
    # Update the platform with the new column positions
    updated_column.each_with_index { |char, row| platform[row][col] = char }
  end

  platform
end

def move_rocks_up(column)
  num_rows = column.length

  (0...num_rows).each do |row|
    next unless column[row] == '.'

    # Find the highest rock below this position that can be moved up
    rock_row = (row + 1...num_rows).find do |r|
      column[r] == 'O' && !column[row + 1...r].include?('#')
    end

    # Move the rock up if found
    unless rock_row.nil?
      column[row] = 'O'
      column[rock_row] = '.'
      # Reset to the position above the moved rock
      row = [0, row + 1].max
    end
  end

  column
end

def calculate_total_load(platform)
  load = 0
  platform.each_with_index do |row, row_idx|
    row.chars.each_with_index do |char, col_idx|
      load += platform.size - row_idx if char == 'O'
    end
    # puts "After row #{row_idx} the load is #{load}"
  end

  load
end

def calculate_load(platform)
  tilted_platform = tilt_platform_north(platform)

  # Debug output
  puts "Tilted Platform:"
  puts tilted_platform

  calculate_total_load(tilted_platform)
end

platform = read_and_parse_input('data/day14_test.txt')
total_load = calculate_load(platform)
puts "Total load on the north support beams: #{total_load}"


############## PART 2 #################

def tilt_platform_west(platform)
  num_rows = platform.length

  (0...num_rows).each do |row|
    # Move rounded rocks left in the row
    updated_row = move_rocks_left(platform[row])
    # Update the platform with the new column positions
    platform[row] = updated_row
  end

  platform
end

def move_rocks_left(row)
  updated_row = row.dup
  num_cols = row.length

  (0...num_cols).each do |col|
    next unless updated_row[col] == '.'

    # Find the highest rock right from this position that can be moved to the left
    rock_col = (col + 1...num_cols).find do |r|
      updated_row[r] == 'O' && !updated_row[col + 1...r].include?('#')
    end

    # Move the rock left if found
    unless rock_col.nil?
      updated_row[col] = 'O'
      updated_row[rock_col] = '.'
      # Reset to the position above the moved rock
      col = [0, col + 1].max
    end
  end

  updated_row
end

def tilt_platform_south(platform)
  num_cols = platform.first.length

  (0...num_cols).each do |col|
    column = platform.map { |row| row[col] }
    reversed_column = column.reverse
    # Move rounded rocks up in the column
    updated_column_reversed = move_rocks_up(reversed_column)
    # Update the platform with the new column positions
    updated_column = updated_column_reversed.reverse
    updated_column.each_with_index { |char, row| platform[row][col] = char }
  end

  platform
end

def tilt_platform_east(platform)
  num_rows = platform.length

  (0...num_rows).each do |row|
    # Move rounded rocks left in the row
    reversed_row = platform[row].reverse
    updated_row_reversed = move_rocks_left(reversed_row)
    # Update the platform with the new column positions
    platform[row] = updated_row_reversed.reverse
  end

  platform
end


def run_cycle(platform, debug_out = false)
  platform = tilt_platform_north(platform)
  platform = tilt_platform_west(platform)
  platform = tilt_platform_south(platform)
  platform = tilt_platform_east(platform)

  # Debug output
  if debug_out
    puts "Tilted Platform after cycle:"
    puts platform
  end

  platform
end

def run_cycles(platform, nb_cycles)
  (0...nb_cycles).each do |i|
    #puts "Running cycle #{i+1}"
    platform = run_cycle(platform)
    puts "#{i}, #{calculate_total_load(platform)}"
  end
  platform
end

#platform = read_and_parse_input('data/day14.txt')
#platform = run_cycles(platform, 500)

def detect_pattern_and_calculate_cycles(platform, total_cycles)
  seen_states = {}
  current_cycle = 0

  while current_cycle < total_cycles
    platform = run_cycle(platform)
    platform_state = platform.join

    if seen_states.include?(platform_state)
      previous_cycle = seen_states[platform_state]
      cycle_length = current_cycle - previous_cycle

      # Calculate how many cycles remain after pattern is detected
      remaining_cycles = (total_cycles - current_cycle) % cycle_length
      return calculate_remaining_cycles(platform, remaining_cycles)
    else
      seen_states[platform_state] = current_cycle
    end

    current_cycle += 1
  end

  platform
end

def calculate_remaining_cycles(platform, remaining_cycles)
  remaining_cycles.times { platform = run_cycle(platform) }
  platform
end

initial_platform = read_and_parse_input('data/day14.txt')
final_platform = detect_pattern_and_calculate_cycles(initial_platform, (1000000000-1))

puts "Solution for part 2: #{calculate_total_load(final_platform)}"


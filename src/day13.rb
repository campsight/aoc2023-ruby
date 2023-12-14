def read_and_parse_input(file_path)
  patterns = File.read(file_path).split("\n\n").map { |pattern| pattern.split("\n") }
  patterns
end

def find_reflections(pattern)
  vertical_reflections = find_vertical_reflections(pattern)
  horizontal_reflections = find_horizontal_reflections(pattern)

  # Debug output
  #puts "Vertical Reflections: #{vertical_reflections}"
  #puts "Horizontal Reflections: #{horizontal_reflections}"

  [vertical_reflections, horizontal_reflections]
end

def find_vertical_reflections(pattern)
  num_cols = pattern[0].length
  reflections = []

  # Check for potential mirror lines
  (1...num_cols).each do |mirror_line|
    # Define the range for comparison (shortest side of the mirror line)
    range = [mirror_line, num_cols - mirror_line].min

    # Check if the pattern mirrors correctly across this line
    is_reflection = (1..range).all? do |offset|
      pattern.all? do |row|
        row[mirror_line - offset] == row[mirror_line + offset - 1]
      end
    end

    reflections.push(mirror_line) if is_reflection
  end

  reflections
end


def find_horizontal_reflections(pattern)
  num_rows = pattern.length
  reflections = []

  # Check for potential mirror lines
  (1...num_rows).each do |mirror_line|
    # Define the range for comparison (shortest side of the mirror line)
    range = [mirror_line, num_rows - mirror_line].min

    # Check if the pattern mirrors correctly across this line
    is_reflection = (1..range).all? do |offset|
      pattern[mirror_line - offset].chars.each_with_index.all? do |char, col|
        char == pattern[mirror_line + offset - 1][col]
      end
    end

    reflections.push(mirror_line) if is_reflection
  end

  reflections
end

def calculate_summary(pattern)
  vertical_reflections, horizontal_reflections = find_reflections(pattern)
  summary = vertical_reflections.sum + horizontal_reflections.sum * 100
  summary
end

def process_patterns(file_path)
  patterns = read_and_parse_input(file_path)
  total_summary = 0

  patterns.each do |pattern|
    vertical_reflections, horizontal_reflections = find_reflections(pattern)
    summary = vertical_reflections.sum + horizontal_reflections.sum * 100
    total_summary += summary

    # Debug output for each pattern
    puts "Vertical Reflections: #{vertical_reflections}, Horizontal Reflections: #{horizontal_reflections}"
    puts "Pattern Summary: #{summary}\n\n"
  end

  total_summary
end

file_path = 'data/day13.txt'  # Replace with the path to your input file
total_summary = process_patterns(file_path)
puts "Total number: #{total_summary}"

### PART 2 ###

def process_patterns_with_smudges(file_path)
  patterns = read_and_parse_input(file_path)
  total_summary = 0

  patterns.each do |pattern|
    original_vertical_reflections, original_horizontal_reflections = find_reflections(pattern)
    pattern_reflection_found = false

    # Iterate through each cell to find and fix the smudge
    pattern.each_with_index do |row, row_idx|
      if pattern_reflection_found
        break
      end
      row.chars.each_with_index do |char, col_idx|
        next if char == '?'  # Skip unknown cells

        # Fix the smudge
        modified_pattern = pattern.map(&:clone)
        modified_pattern[row_idx][col_idx] = char == '#' ? '.' : '#'

        # Find new reflections
        new_vertical_reflections, new_horizontal_reflections = find_reflections(modified_pattern)

        # Find new reflections
        reflection_info = new_reflection_found?(original_vertical_reflections, new_vertical_reflections, original_horizontal_reflections, new_horizontal_reflections)

        # Check if a new reflection line is found
        if reflection_info
          reflection_type, reflection_index = reflection_info
          summary = reflection_type == :vertical ? reflection_index : reflection_index * 100
          total_summary += summary
          pattern_reflection_found = true

          # Debug output
          puts "Found new reflection in pattern after fixing smudge at [#{row_idx}, #{col_idx}]:"
          puts "Summary for this pattern: #{summary}\n\n"

          break
        end
      end
    end
  end

  total_summary
end

def new_reflection_found?(original_vertical, new_vertical, original_horizontal, new_horizontal)
  # Check for new vertical reflection lines
  new_vertical.each do |v_ref|
    unless original_vertical.include?(v_ref)
      return [:vertical, v_ref]  # Return type and column index
    end
  end

  # Check for new horizontal reflection lines
  new_horizontal.each do |h_ref|
    unless original_horizontal.include?(h_ref)
      return [:horizontal, h_ref]  # Return type and row index
    end
  end

  nil  # Return nil if no new reflection is found
end


total_summary = process_patterns_with_smudges(file_path)
puts "Total number Part 2: #{total_summary}"
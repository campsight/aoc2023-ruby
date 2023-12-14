require 'memoist'

extend Memoist

def read_and_parse_input(file_path)
  conditions = []
  File.open(file_path, 'r').each do |line|
    springs, group_sizes = line.strip.split(' ')
    conditions << { springs: springs.split(''), group_sizes: group_sizes.split(',').map(&:to_i) }
  end
  conditions
end

def count_arrangements(line, counts, pos = 0, current_count = 0, countpos = 0)
  # Base cases
  if pos == line.length
    arrangements = countpos == counts.length ? 1 : 0
    # puts "Line completed: #{line.join}, Arrangements: #{arrangements}" if arrangements > 0
    return arrangements
  end

  # Debug: Print the current state
  #puts "Current line: #{line.join}, Pos: #{pos}, Current Count: #{current_count}, Countpos: #{countpos}"

  if line[pos] == '#'
    count_arrangements(line, counts, pos + 1, current_count + 1, countpos)
  elsif line[pos] == '.' || countpos == counts.length
    arrangements = 0
    if current_count == counts[countpos] || countpos == counts.length
      arrangements += count_arrangements(line, counts, pos + 1, 0, countpos + 1)
    end
    if current_count == 0
      arrangements += count_arrangements(line, counts, pos + 1, 0, countpos)
    end
    arrangements
  else
    # '?' case: explore both possibilities
    arrangements = count_arrangements(line.clone.fill('#', pos, 1), counts, pos + 1, current_count + 1, countpos)
    if current_count == counts[countpos] || countpos == counts.length
      arrangements += count_arrangements(line.clone.fill('.', pos, 1), counts, pos + 1, 0, countpos + 1)
    end
    if current_count == 0
      arrangements += count_arrangements(line.clone.fill('.', pos, 1), counts, pos + 1, 0, countpos)
    end
    arrangements
  end
end
memoize :count_arrangements

def getcount(line, counts, pos, current_count, countpos)
  # pos is the next character to be processed
  # current_count is how far into the current sequence of #s we are in
  # countpos is how many sequences of #s we have already finished
  if pos == len(line)
    ret = counts.length == countpos ? 1 : 0
  elsif line[pos] == '#'
    ret = getcount(line, counts, pos + 1, current_count + 1, countpos)
  elsif line[pos] == '.' or countpos == len(counts)
    if countpos < len(counts) and current_count == counts[countpos]
      ret = getcount(line, counts, pos + 1, 0, countpos + 1)
    elsif current_count == 0
      ret = getcount(line, counts, pos + 1, 0, countpos)
    else
      ret = 0
    end
  else
      hash_count = getcount(line, counts, pos + 1, current_count + 1, countpos)
    dot_count = 0
    if current_count == counts[countpos]
      dot_count = getcount(line, counts, pos + 1, 0, countpos + 1)
    elsif current_count == 0
      dot_count = getcount(line, counts, pos + 1, 0, countpos)
    end

    ret = hash_count + dot_count
  end
  ret
end


def sum_of_arrangements(file_path)
  conditions = read_and_parse_input(file_path)
  total_arrangements = 0

  conditions.each do |condition|
    arrangements = count_arrangements(condition[:springs] + ['.'], condition[:group_sizes])
    total_arrangements += arrangements
    # Debug: Print arrangements for each line
    puts "Line: #{condition[:springs].join}, Total Arrangements: #{arrangements}"
  end

  total_arrangements
end

def read_and_parse_input2(file_path)
  unfolded_conditions = []

  File.open(file_path, 'r').each do |line|
    springs, group_sizes = line.strip.split(' ')

    # Unfold springs and group sizes
    unfolded_springs = ([springs] * 5).join('?')
    unfolded_group_sizes = ([group_sizes] * 5).join(',')

    unfolded_conditions << {
      springs: unfolded_springs.split(''),
      group_sizes: unfolded_group_sizes.split(',').map(&:to_i)
    }
  end

  unfolded_conditions
end



def unfold_conditions_sum(file_path)
  conditions = read_and_parse_input2(file_path)

  total_arrangements = 0

  conditions.each do |condition|
    arrangements = count_arrangements(condition[:springs] + ['.'], condition[:group_sizes])
    total_arrangements += arrangements
    # Debug: Print arrangements for each line
    puts "Line: #{condition[:springs].join}, Total Arrangements: #{arrangements}"
  end
end

file_path = 'data/day12_test.txt'  # Replace with the path to your input file
total_arrangements = sum_of_arrangements(file_path)
puts "Total number of arrangements: #{total_arrangements}"
total_arrangements_unfolded = unfold_conditions_sum(file_path)
puts "Total number of arrangements (unfolded): #{total_arrangements_unfolded}"


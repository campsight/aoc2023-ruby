def generate_difference_sequences(values)
  sequences = [values]
  while sequences.last.any? { |x| x != 0 }
    last_seq = sequences.last
    new_seq = last_seq.each_cons(2).map { |a, b| b - a }
    sequences << new_seq
  end
  sequences
end

def extrapolate_next_value(sequences)
  last_value = sequences.first.last
  sequences[1..].each do |seq|
    last_value += seq.last
  end
  last_value
end

def sum_extrapolated_values(file_path)
  lines = File.readlines(file_path).map(&:chomp)
  lines.sum do |line|
    values = line.split.map(&:to_i)
    sequences = generate_difference_sequences(values)
    extrapolate_next_value(sequences)
  end
end

file_path = 'data/day9.txt'  # Replace with the path to your input file
total = sum_extrapolated_values(file_path)
puts "Sum of extrapolated values: #{total}"

### PART 2 ######################
def extrapolate_previous_value(sequences)
  # Start with zero for the extrapolated previous value
  previous_value = 0
  puts "sequences: #{sequences}"
  # Iterate from the bottom sequence upwards
  sequences.reverse_each do |seq|
    # The previous value is adjusted by the first value of the current sequence
    previous_value = seq.first - previous_value
    puts "Adjusting with #{seq.first || 0}, new previous value: #{previous_value}"  # Debug
  end

  previous_value
end



def sum_extrapolated_previous_values(file_path)
  lines = File.readlines(file_path).map(&:chomp)
  lines.sum do |line|
    values = line.split.map(&:to_i)
    sequences = generate_difference_sequences(values)
    extrapolate_previous_value(sequences)
  end
end

total = sum_extrapolated_previous_values(file_path)
puts "Sum of extrapolated previous values: #{total}"

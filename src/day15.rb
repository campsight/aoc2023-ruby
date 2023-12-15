def hash_algorithm(string)
  current_value = 0

  string.each_char do |char|
    ascii_value = char.ord
    current_value = (current_value + ascii_value) * 17
    current_value %= 256
  end

  current_value
end

def process_initialization_sequence(file_path)
  # Read the input file and remove newline characters
  sequence = File.read(file_path).tr("\n", '')

  # Split the sequence into individual steps
  steps = sequence.split(',')

  # Run the HASH algorithm on each step and sum the results
  steps.sum { |step| hash_algorithm(step) }
end

total_sum = process_initialization_sequence('data/day15.txt')
puts "Total sum of the results: #{total_sum}"



##### PART 2 ##############
boxes = Array.new(256) { [] }

def process_step(boxes, step)
  label, operation = step.split(/(-|=)/)
  box_index = hash_algorithm(label) % 256
  case operation
  when '-'
    remove_lens(boxes, box_index, label)
  when '='
    focal_length = step.split('=').last.to_i
    add_or_replace_lens(boxes, box_index, label, focal_length)
  end
end

def remove_lens(boxes, box_index, label)
  boxes[box_index].reject! { |lens| lens[:label] == label }
end

def add_or_replace_lens(boxes, box_index, label, focal_length)
  existing_lens_index = boxes[box_index].index { |lens| lens[:label] == label }
  if existing_lens_index
    boxes[box_index][existing_lens_index] = { label: label, focal_length: focal_length }
  else
    boxes[box_index].push({ label: label, focal_length: focal_length })
  end
end

def calculate_focusing_power(boxes)
  total_power = 0

  boxes.each_with_index do |box, box_index|
    box.each_with_index do |lens, slot_index|
      box_number = box_index + 1
      slot_number = slot_index + 1
      focal_length = lens[:focal_length]
      total_power += box_number * slot_number * focal_length
    end
  end

  total_power
end

def run_initialization_sequence(file_path)
  boxes = Array.new(256) { [] }
  sequence = File.read(file_path).tr("\n", '').split(',')

  sequence.each do |step|
    process_step(boxes, step)
  end

  calculate_focusing_power(boxes)
end

focusing_power = run_initialization_sequence('data/day15.txt')
puts "Total focusing power: #{focusing_power}"

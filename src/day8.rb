def read_and_parse_input(file_path)
  content = File.read(file_path)
  instructions_part, map_part = content.split("\n\n")

  instructions = instructions_part.strip
  network_lines = map_part.split("\n")

  [instructions, network_lines]
end

def parse_network(network_lines)
  network = {}
  network_lines.each do |line|
    node, neighbors = line.split(' = ')
    left, right = neighbors.delete('()').split(', ')
    network[node] = [left, right]
  end
  network
end

def follow_instructions(network, instructions)
  current_node = 'AAA'
  step_count = 0

  instructions.chars.cycle do |direction|
    step_count += 1
    current_node = network[current_node][direction == 'L' ? 0 : 1]
    break if current_node == 'ZZZ'
  end

  step_count
end

def steps_to_reach_zzz(file_path)
  instructions, network_lines = read_and_parse_input(file_path)
  network = parse_network(network_lines)
  follow_instructions(network, instructions)
end

file_path = 'data/day8.txt'  # Replace with the path to your input file
#steps = steps_to_reach_zzz(file_path)
#puts "Steps to reach ZZZ: #{steps}"


#### PART 2 ##############################################

def find_starting_nodes(network)
  network.keys.select { |node| node.end_with?('A') }
end

def follow_instructions_simultaneously(network, instructions, starting_nodes)
  current_nodes = starting_nodes
  step_count = 0

  instructions.chars.cycle do |direction|
    step_count += 1
    current_nodes = current_nodes.map do |node|
      next_node = network[node][direction == 'L' ? 0 : 1]
      next_node
    end

    break if current_nodes.all? { |node| node.end_with?('Z') }
  end

  step_count
end

def steps_to_reach_all_z(file_path)
  instructions, network_lines = read_and_parse_input(file_path)
  network = parse_network(network_lines)
  starting_nodes = find_starting_nodes(network)
  follow_instructions_simultaneously(network, instructions, starting_nodes)
end

steps = steps_to_reach_all_z(file_path)
puts "Steps to reach all 'Z' nodes: #{steps}"


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

def find_starting_nodes(network)
  network.keys.select { |node| node.end_with?('A') }
end


def calculate_cycle(network, instructions, start_node)
  current_node = start_node
  visited = {}
  step = 0

  instructions.chars.cycle do |direction|
    # Record the step number the first time a node is visited
    if visited[current_node].nil?
      visited[current_node] = step
    elsif current_node.end_with?('Z')
      # Return the first visit step and the cycle length
      return [visited[current_node], step - visited[current_node]]
    end

    current_node = network[current_node][direction == 'L' ? 0 : 1]
    step += 1
  end
end

require 'set'

def lcm(nums)
  nums.reduce(1) { |lcm, num| lcm.lcm(num) }
end

def steps_to_reach_all_z_b(file_path)
  instructions, network_lines = read_and_parse_input(file_path)
  network = parse_network(network_lines)
  starting_nodes = find_starting_nodes(network)

  cycles = Set.new
  starting_nodes.each do |node|
    first_step, cycle_length = calculate_cycle(network, instructions, node)
    cycles.add([first_step, cycle_length])
  end

  # Calculate the step where all nodes end on 'Z'
  lcm(cycles.map(&:last))
end

file_path = 'data/day8.txt'  # Replace with your actual file path
steps = steps_to_reach_all_z_b(file_path)
puts "Steps to reach all 'Z' nodes: #{steps}"

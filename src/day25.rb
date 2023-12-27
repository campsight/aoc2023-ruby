require 'set'

def read_input(file_name)
  graph = {}
  File.readlines(file_name).each do |line|
    node, edges = line.strip.split(': ')
    graph[node] ||= Set.new
    edges.split(' ').each do |edge|
      graph[node].add(edge)
      graph[edge] ||= Set.new
      graph[edge].add(node)
    end
  end
  graph
end

# Depth-first search to find the size of the connected component
def dfs(graph, node, visited)
  return 0 if visited.include?(node)
  visited.add(node)
  size = 1
  if graph[node] == nil
    return size
  end
  graph[node].each do |neighbor|
    size += dfs(graph, neighbor, visited) if graph.key?(neighbor)
  end
  size
end

# Evaluate the graph after disconnections and calculate the product of the two group sizes
def evaluate_disconnection(graph, disconnections)
  # Temporarily remove the connections
  disconnections.each do |(a, b)|
    graph[a].delete(b) if graph[a]
    graph[b].delete(a) if graph[b]
  end

  visited = Set.new
  components = []

  # Find the sizes of all components
  graph.keys.each do |node|
    unless visited.include?(node)
      component_size = dfs(graph, node, visited)
      components << component_size if component_size > 0
    end
  end

  # Restore the connections
  disconnections.each do |(a, b)|
    graph[a].add(b) unless graph[a].nil?
    graph[b].add(a) unless graph[b].nil?
  end

  # Check if the graph was split into exactly two groups
  if components.length == 2
    puts "Found two disconnected groups. Group1 = #{components[0]}, Group 2 = #{components[1]}"
    components[0] * components[1]
  else
    Float::INFINITY  # Return an invalid product if not exactly two groups
  end
end

# Simple BFS to find one path between two nodes
def find_path(graph, start_node, end_node)
  visited = Set.new([start_node])
  queue = [[start_node, [start_node]]]  # Queue of [node, path_to_node]

  while !queue.empty?
    current_node, path = queue.shift
    return path if current_node == end_node

    graph[current_node].each do |neighbor|
      next if visited.include?(neighbor)
      visited.add(neighbor)
      queue.push([neighbor, path + [neighbor]])
    end
  end

  nil  # Return nil if no path found
end

# Main execution flow
file_name = 'data/day25.txt'  # Update with the path to your input file
graph = read_input(file_name)
edge_counts = Hash.new(0)

# Find paths between 100 random pairs of nodes and count edge frequencies
400.times do
  nodes = graph.keys.sample(2)
  path = find_path(graph, nodes[0], nodes[1])
  next if path.nil?

  # Increment the count for each edge in the path
  path.each_cons(2) { |a, b| edge_counts[[a, b].sort] += 1 }
end

# Select the three edges that were traversed most frequently
disconnections = edge_counts.keys.sort_by { |k| -edge_counts[k] }.first(3)

puts "Best Disconnection: #{disconnections}"
puts "Product of the sizes of the two groups: #{evaluate_disconnection(graph, disconnections)}"

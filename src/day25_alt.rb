require 'set'

def read_input(file_name)
  graph = {}
  File.readlines(file_name).each do |line|
    node, edges = line.strip.split(': ')
    graph[node] ||= Set.new
    edges.split(' ').each do |edge|
      graph[node].add(edge)
      # Ensure the connection is bidirectional
      graph[edge] ||= Set.new
      graph[edge].add(node)
    end
  end
  graph
end

def kargers_min_cut(graph)
  # Initialize a hash to keep track of the nodes within each super node
  super_node_members = {}
  graph.keys.each { |node| super_node_members[node] = [node] }

  while graph.length > 2
    # Randomly select an edge (u, v)
    u = graph.keys.sample
    v = (graph[u].to_a - [u]).sample

    raise "Node '#{u}' or '#{v}' does not exist in the graph" if graph[u].nil? || graph[v].nil?

    # Merge nodes u and v into a single node called 'merged'
    merged = "#{u}_#{v}"
    graph[merged] = (graph[u] + graph[v]).to_set - [u, v]
    super_node_members[merged] = super_node_members[u] + super_node_members[v]

    # Remove the old nodes
    graph.delete(u)
    graph.delete(v)
    super_node_members.delete(u)
    super_node_members.delete(v)

    # Update all connections that used to point to u or v to point to the merged node
    graph[merged].each do |neighbor|
      graph[neighbor].delete(u).delete(v) # Remove old connections
      graph[neighbor].add(merged)         # Add new connection
    end

    # Remove self-loops
    graph[merged].delete(merged)
  end

  # The sizes of the two groups are the counts of the original nodes in the final two super nodes
  group_sizes = graph.keys.map { |super_node| super_node_members[super_node].length }
  group_sizes
end


# Main execution flow
file_name = 'data/day25_test.txt'  # Update with the path to your input file
graph = read_input(file_name)
min_cut = Float::INFINITY
best_group_sizes = []

# Run Karger's algorithm multiple times to increase the chance of finding the actual minimum cut
(1..(graph.length ** 2)).each do
  graph_copy = Marshal.load(Marshal.dump(graph))  # Deep copy the graph for each iteration
  group_sizes = kargers_min_cut(graph_copy)
  cut_size = group_sizes.sum - 2  # The total number of edges minus the internal edges of the last two super nodes

  if cut_size < min_cut
    min_cut = cut_size
    best_group_sizes = group_sizes
  end
end

puts "Best group sizes: #{best_group_sizes}"

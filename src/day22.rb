# Class to represent a brick
class Brick
  attr_accessor :coords, :supported_by, :supports, :id, :extruded, :direction

  def initialize(coords, id, extruded = false, direction = nil)
    @coords = coords
    @supported_by = []
    @supports = []
    @id = id
    @extruded = extruded
    @direction = direction
    self.extrude
  end


  # Define a clone method
  def clone
    cloned_brick = Brick.new(@coords.clone, @id, @extruded, @direction)
    cloned_brick.supported_by = @supported_by.clone
    cloned_brick.supports = @supports.clone
    cloned_brick
  end

  # Check if this brick is supporting another brick
  def supports?(other)
    other.supported_by.include?(self.id)
  end

  # Get lowestZ value (bottom of the brick)
  def get_bottom_z
    @coords[0][2]
  end

  # Method to get a string representation of the Brick
  def to_s
    "Brick ID: #{@id}, Coordinates: #{@coords}, Extruded: #{@extruded}, direction: #{@direction}, Supports: #{@supports}, Supported By: #{@supported_by}"
  end

  # Each brick is made up of a single straight line of cubes, so extrusion is only needed in one direction
  def extrude
    unless @extruded
      b_direction = nil
      b_start = nil
      b_end = nil
      # Check in which direction to extrude
      (0..2).each do |dir|
        b_dir_start = self.coords[0]
        b_dir_end = self.coords[1]
        if b_dir_start[dir] != b_dir_end[dir]
          b_direction = dir # we have found the correct direction
          b_start, b_end = b_dir_start[dir] < b_dir_end[dir] ? [b_dir_start, b_dir_end] : [b_dir_end, b_dir_start]
        end
      end

      if b_direction.nil? # if we didn't find a direction, the brick is a single point
        @coords = [@coords[0]]
      else
        @direction = b_direction
        new_coords = []
        (b_start[b_direction]..b_end[b_direction]).each do |coord|
          new_coords.append(b_start.each_with_index.map { |current_value, dir| dir != b_direction ? current_value : coord })
        end
        new_coords = new_coords.sort_by { |coord| coord[2] } # Sort by z
        @coords = new_coords
      end
    end

    @extruded = true
  end
end

# Function to clone an array of bricks
def clone_bricks(bricks)
  # First pass: create a shallow clone of each brick and a mapping of old to new bricks
  mapping = {}
  cloned_bricks = bricks.map do |brick|
    cloned_brick = brick.clone  # This creates a shallow clone
    mapping[brick] = cloned_brick
    cloned_brick
  end

  # Second pass: update the relationships in each cloned brick
  cloned_bricks.each { |brick| brick.deep_clone(mapping) }

  cloned_bricks
end


# Read the input file and create bricks
def read_input(file_path)
  bricks = []
  File.foreach(file_path).with_index do |line, index|
    coords = line.strip.split('~').map { |coord| coord.split(',').map(&:to_i) }
    bricks << Brick.new(coords, index)
  end
  bricks
end

# Determine where each brick will settle
def settle_bricks(s_bricks, debug = false)
  floor = Set.new
  dropped = Set.new
  new_brick_set = []

  s_bricks.each_with_index do |brick, i|
    while true
      b_start = brick.coords[0]
      z_coord = b_start[2]
      bottom_bricks = brick.coords.select { |b| b[2] == z_coord }  # get all bricks with the same z_coord

      # check if this brick can still be lowered. If not => position it here. If it can => lower it.
      if bottom_bricks.any? { |coord| floor.include?([coord[0], coord[1], coord[2]-1]) } || b_start[2] == 1 # floor is at 0, lowest brick at 1
        new_brick_set.append(brick)
        brick.coords.each { |coord| floor.add(coord) }
        break
      else
        brick.coords = brick.coords.map { |coord| [coord[0], coord[1], coord[2]-1] }
        dropped.add(i)
      end
    end
  end

  [new_brick_set, dropped.length]
end

# Build support relationships between bricks
def build_relationships(bricks, debug = false)
  bricks.each do |brick|
    z_high = brick.coords.last[2]
    bricks_one_above = bricks.select do |br|
      br.coords.first[2] == z_high + 1
    end
    bda = bricks_directly_above(brick, bricks_one_above)
    if debug
      puts "Brick #{brick} directly underneath #{bda.count} bricks."
    end
    bda.each do |bda_brick|
      brick.supports.append(bda_brick.id)
      bda_brick.supported_by.append(brick.id)
    end
  end
end


def bricks_directly_above(current_brick, bricks_one_above)
  above_bricks = []

  if current_brick.direction == 2 || current_brick.direction.nil?
    # The current brick is standing up or consists of a single coordinate
    top_coord = current_brick.coords.last
    bricks_one_above.each do |above_brick|
      above_brick.coords.each do |above_coord|
        if above_coord[0] == top_coord[0] && above_coord[1] == top_coord[1]
          above_bricks << above_brick unless above_bricks.include?(above_brick)
        end
      end
    end
  else
    # The current brick lays flat in the x,y plane
    current_brick.coords.each do |current_coord|
      bricks_one_above.each do |above_brick|
        if above_brick.coords.any? { |ac| ac[0] == current_coord[0] && ac[1] == current_coord[1] }
          above_bricks << above_brick unless above_bricks.include?(above_brick)
        end
      end
    end
  end

  above_bricks
end

# Determine safe disintegrations
def safe_disintegrations(bricks)
  safe_count = 0

  bricks.each do |brick|
    # A brick can be safely disintegrated if all the bricks it supports
    # would still be supported by other bricks after its removal.
    can_disintegrate = brick.supports.all? do |supported_id|
      # Find the brick corresponding to the supported_id
      supported_brick = bricks.find { |b| b.id == supported_id }

      # Check if other bricks still support the supported_brick
      (supported_brick.supported_by - [brick.id]).any?
    end

    safe_count += 1 if can_disintegrate
  end

  safe_count
end



# Main function to solve the puzzle
def solve_puzzle(file_path, debug = false)
  bricks = read_input(file_path)
  if debug
    puts "Original bricks: "
    puts bricks
    puts ""
  end
  sorted_bricks = bricks.sort_by { |brick| brick.get_bottom_z }
  if debug
    puts "Sorted bricks: "
    puts sorted_bricks
    puts ""
  end
  settled_bricks, _ = settle_bricks(sorted_bricks, debug)
  if debug
    puts "Settled bricks: "
    puts settled_bricks
    puts ""
  end

  build_relationships(settled_bricks, debug)
end

# Read the puzzle input and solve
file_path = 'data/day22.txt'
final_bricks = solve_puzzle(file_path)
puts "Number of bricks that can be safely disintegrated: #{safe_disintegrations(final_bricks)}"


########## part 2 #################
def count_fallen_bricks(bricks)
  total_fallen = 0

  bricks.each do |brick|
    # Simulate disintegration of the brick
    fallen_bricks = simulate_disintegration(brick, bricks)

    # Count the fallen bricks and add to the total
    total_fallen += fallen_bricks.count
  end

  total_fallen
end

def simulate_disintegration(target_brick, bricks)
  # Clone the bricks array to avoid modifying the original
  temp_bricks = bricks.map(&:clone)

  # Remove the target brick to simulate disintegration
  temp_bricks.delete_if { |brick| brick.id == target_brick.id }

  # Find and return the bricks that would fall as a result
  find_fallen_bricks(target_brick, temp_bricks)
end


def find_fallen_bricks(target_brick, remaining_bricks)
  fallen_bricks_ids = [target_brick.id]  # Start with the target brick as fallen
  newly_fallen = true

  while newly_fallen
    newly_fallen = false

    remaining_bricks.each do |brick|
      # Skip if the brick is already marked as fallen
      next if fallen_bricks_ids.include?(brick.id) || brick.supported_by.empty?

      # If all of the supporting bricks have fallen, mark this brick as fallen
      if (brick.supported_by - fallen_bricks_ids).empty?
        fallen_bricks_ids << brick.id
        newly_fallen = true  # We've found a new fallen brick, so we need to check again
      end
    end
  end

  # Exclude the initially disintegrated brick and convert fallen brick IDs back to brick objects
  remaining_bricks.select { |brick| fallen_bricks_ids.include?(brick.id) && brick.id != target_brick.id }
end

puts "Total bricks that would fall: #{count_fallen_bricks(final_bricks)}"

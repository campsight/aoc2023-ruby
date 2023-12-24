def parse_input(file)
  hailstones = []
  File.foreach(file) do |line|
    position, velocity = line.split(' @ ')
    px, py, pz = position.split(', ').map(&:to_i)
    vx, vy, vz = velocity.split(', ').map(&:to_i)
    hailstones << { position: [px, py, pz], velocity: [vx, vy, vz] }
  end
  hailstones
end

def calculate_position_at_time(t, initial_position, velocity)
  x0, y0 = initial_position
  vx, vy = velocity

  x_t = x0 + vx * t
  y_t = y0 + vy * t

  [x_t, y_t]
end

def calculate_intersection(t, x0, y0, vx, vy, axis, value, min_x, max_x, min_y, max_y, tolerance = 0.1)
  x = x0 + vx * t
  y = y0 + vy * t

  if t >= 0
    if axis == :x
      if x.between?(min_x - tolerance, max_x + tolerance) && y.between?(min_y - tolerance, max_y + tolerance)
        [x, y]
      end
    else
      if y.between?(min_y - tolerance, max_y + tolerance) && x.between?(min_x - tolerance, max_x + tolerance)
        [x, y]
      end
    end
  end
end


def find_intersection(initial_position, velocity, min_x, max_x, min_y, max_y)
  x0, y0 = initial_position
  vx, vy = velocity
  intersections = []
  start_point = initial_position

  # Check if the initial position is inside the confined space
  inside = x0.between?(min_x, max_x) && y0.between?(min_y, max_y)

  # Check for intersection with left edge (x = min_x)
  if vx != 0
    t = (min_x - x0).to_f / vx
    intersection = calculate_intersection(t, x0, y0, vx, vy, :x, min_x, min_x, max_x, min_y, max_y)
    intersections << intersection if intersection
  end

  # Check for intersection with right edge (x = max_x)
  if vx != 0
    t = (max_x - x0).to_f / vx
    intersection = calculate_intersection(t, x0, y0, vx, vy, :x, max_x, min_x, max_x, min_y, max_y)
    intersections << intersection if intersection
  end

  # Check for intersection with bottom edge (y = min_y)
  if vy != 0
    t = (min_y - y0).to_f / vy
    intersection = calculate_intersection(t, x0, y0, vx, vy, :y, min_y, min_x, max_x, min_y, max_y)
    intersections << intersection if intersection
  end

  # Check for intersection with top edge (y = max_y)
  if vy != 0
    t = (max_y - y0).to_f / vy
    intersection = calculate_intersection(t, x0, y0, vx, vy, :y, max_y, min_x, max_x, min_y, max_y)
    intersections << intersection if intersection
  end

  # Determine the line segment based on the initial position and intersections
  if inside
    # Start from the initial position to the first intersection
    [start_point, intersections.first].compact
  elsif intersections.length >= 2
    # Sort intersections based on distance from the initial position and take the first two
    intersections.compact.sort_by { |point| (point[0] - x0)**2 + (point[1] - y0)**2 }[0..1]
  else
    # No valid line segment if there are fewer than 2 intersections and the point starts outside
    []
  end
end

# Example usage:
initial_position = [2, 3]
velocity = [4, 5]
min_x, max_x, min_y, max_y = [7, 27, 7, 27]
line_segment = find_intersection(initial_position, velocity, min_x, max_x, min_y, max_y)
puts "Line Segment: #{line_segment}"

def line_segments_intersect?(seg1, seg2)
  # Check if either segment is empty, indicating no path within the confined space
  return false if seg1.empty? || seg2.empty?

  # Extract points from segments
  ax1, ay1, ax2, ay2 = seg1.flatten
  bx1, by1, bx2, by2 = seg2.flatten

  # Calculate direction of the points wrt the line
  d1 = (bx2 - bx1) * (ay1 - by1) - (by2 - by1) * (ax1 - bx1)
  d2 = (bx2 - bx1) * (ay2 - by1) - (by2 - by1) * (ax2 - bx1)
  d3 = (ax2 - ax1) * (by1 - ay1) - (ay2 - ay1) * (bx1 - ax1)
  d4 = (ax2 - ax1) * (by2 - ay1) - (ay2 - ay1) * (bx2 - ax1)

  # Check if the segments intersect
  ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))
end

def intersect?(h1, h2, min_x, max_x, min_y, max_y)
  px1, py1 = h1[:position][0], h1[:position][1]
  vx1, vy1 = h1[:velocity][0], h1[:velocity][1]
  px2, py2 = h2[:position][0], h2[:position][1]
  vx2, vy2 = h2[:velocity][0], h2[:velocity][1]
  puts "Checking hailstone 1 #{[px1, py1]} vs 2 #{[px2, py2]}"

  dx, dy = vx1 - vx2, vy1 - vy2
  if dx == 0 && dy == 0
    puts "Hailstones are parallel and will never intersect."
    return false
  end

  begin
    t = (px2 - px1).fdiv(dx)
  rescue
    puts "Cannot divide by zero, paths don't intersect."
    return false
  end

  if t < 0
    puts "Paths intersected in the past for these hailstones."
    return false
  end

  intersect_x = px1 + vx1 * t
  intersect_y = py1 + vy1 * t

  if intersect_x.between?(min_x, max_x) && intersect_y.between?(min_y, max_y)
    puts "Hailstones' paths intersect at (#{intersect_x}, #{intersect_y}) within the test area."
    return true
  else
    puts "Hailstones' paths intersect at (#{intersect_x}, #{intersect_y}) outside the test area."
    return false
  end
end


def count_intersections(hailstones, min_x, max_x, min_y, max_y)
  count = 0
  hailstones.combination(2) do |h1, h2|
    # Calculate line segments for each hailstone
    puts "Checking hailstone 1 #{h1[:position]} vs 2 #{h2[:position]}"
    line_segment_h1 = find_intersection(h1[:position], h1[:velocity], min_x, max_x, min_y, max_y)
    line_segment_h2 = find_intersection(h2[:position], h2[:velocity], min_x, max_x, min_y, max_y)
    puts "Segments: #{line_segment_h1} vs 2 #{line_segment_h2}"
    #count += 1 if line_segments_intersect?(line_segment_h1, line_segment_h2)
    if line_segments_intersect?(line_segment_h1, line_segment_h2)
      count += 1
      puts "Intersection found!"
    else
      puts "No no no"
    end
  end
  count
end

# Adjust these paths and values according to your specific puzzle input
input_file = 'data/day24.txt'
hailstones = parse_input(input_file)
min_x, max_x = 200_000_000_000_000, 400_000_000_000_000
min_y, max_y = 200_000_000_000_000, 400_000_000_000_000
#min_x, max_x = 7, 27
#min_y, max_y = 7, 27

puts count_intersections(hailstones, min_x, max_x, min_y, max_y)

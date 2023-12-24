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

def line_intersection(h1, h2)
  delta_x = [h1[:position][0] - (h1[:position][0] + h1[:velocity][0]), h2[:position][0] - (h2[:position][0] + h2[:velocity][0])]
  delta_y = [h1[:position][1] - (h1[:position][1] + h1[:velocity][1]), h2[:position][1] - (h2[:position][1] + h2[:velocity][1])]

  def det(a, b)
    a[0] * b[1] - a[1] * b[0]
  end

  determinant = det(delta_x, delta_y)
  return [nil, nil] if determinant == 0

  d = [det(h1[:position], h1[:velocity]), det(h2[:position], h2[:velocity])]
  x = det(d, delta_x) / determinant
  y = det(d, delta_y) / determinant
  [x, y]
end

def count_intersections(hailstones, min_x, max_x, min_y, max_y)
  count = 0
  hailstones.combination(2) do |h1, h2|
    # Calculate line segments for each hailstone
    puts "Checking hailstone 1 #{h1[:position]} vs 2 #{h2[:position]}"
    x, y = line_intersection(h1, h2)
    puts "Found x,y: #{[x, y]}"

    if x == nil
      puts "Parallel lines, skipping"
      next
    end

    # If it's in the future the signs of the velocity and the delta must be the same
    dx = x - h1[:position][0]
    dy = y - h1[:position][1]
    unless (dx > 0) == (h1[:velocity][0] > 0) and (dy > 0) == (h1[:velocity][1] > 0)
      puts "Intersection in the past for hailstone 1, skipping"
      next
    end

    # Same for second hailstone
    dx = x - h2[:position][0]
    dy = y - h2[:position][1]
    unless (dx > 0) == (h2[:velocity][0] > 0) and (dy > 0) == (h2[:velocity][1] > 0)
      puts "Intersection in the past for hailstone 2, skipping"
      next
    end

    # Check if the intersection is inside the confined space
    if x.between?(min_x, max_x) && y.between?(min_y, max_y)
      count += 1
      puts "INSIDE :-)"
    else
      puts "no no no"
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

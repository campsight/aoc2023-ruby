def parse_input(file_path)
  lines = File.readlines(file_path).map(&:chomp)
  times = lines[0].split(':')[1].split.map(&:to_i)
  distances = lines[1].split(':')[1].split.map(&:to_i)
  [times, distances]
end


def calculate_winning_ways(time, record)
  (0...time).count do |hold_time|
    speed = hold_time
    travel_time = time - hold_time
    distance = speed * travel_time
    distance > record
  end
end

def total_winning_ways(file_path)
  times, distances = parse_input(file_path)
  ways = times.zip(distances).map { |time, distance| calculate_winning_ways(time, distance) }
  ways.reduce(1, :*)
end

file_path = 'data/day6.txt'  # Replace with your actual file path
result = total_winning_ways(file_path)
puts "Total number of ways to win all races: #{result}"

### part 2 ###

def parse_input_single_race(file_path)
  lines = File.readlines(file_path).map(&:chomp)
  time = lines[0].split(':')[1].gsub(/\s+/, '').to_i
  distance = lines[1].split(':')[1].gsub(/\s+/, '').to_i
  [time, distance]
end

def ways_to_win_long_race(file_path)
  time, record_distance = parse_input_single_race(file_path)
  calculate_winning_ways(time, record_distance)
end

result = ways_to_win_long_race(file_path)
puts "Number of ways to win the long race: #{result}"



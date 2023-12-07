def parse_mappings(lines)
  mappings = {}
  current_map = nil

  seeds = lines.first.split(':')[1].split.map(&:to_i)
  #puts "Parsed Seeds: #{seeds}"

  lines[1..].each do |line|
    if line.strip.empty?
      current_map = nil
    elsif line.include?(':')
      current_map = line.split(':')[0].strip.downcase.gsub(' ', '_').gsub('-', '_').to_sym
      mappings[current_map] = []
    elsif current_map
      dest_start, src_start, length = line.split.map(&:to_i)
      mappings[current_map] << [src_start, src_start + length - 1, dest_start]  # Store range as [map_start, src_end, dest_start]
    end
  end

  # Sort each mapping after parsing
  mappings.each do |key, mapping|
    mappings[key] = mapping.sort_by { |_, src_start, _| src_start }
  end

  #puts "Parsed Mappings: #{mappings}"
  [seeds, mappings]
end

def apply_mapping(number, mapping)
  return number unless mapping
  mapping.each do |src_start, src_end, dest_start|
    if number.between?(src_start, src_end)
      offset = number - src_start
      return dest_start + offset
    end
  end
  number  # Return the number itself if not in any range
end

def process_seed(seed, mappings)
  categories = [:seed_to_soil_map, :soil_to_fertilizer_map, :fertilizer_to_water_map, :water_to_light_map, :light_to_temperature_map, :temperature_to_humidity_map, :humidity_to_location_map]
  categories.reduce(seed) do |result, category|
    apply_mapping(result, mappings[category])
  end
end

# Replace 'path_to_your_input_file.txt' with the actual path to your input file
t1 = Time.now
file_path = 'data/day5.txt'
lines = File.readlines(file_path).map(&:chomp)
seeds, mappings = parse_mappings(lines)

lowest_location = seeds.map { |seed| process_seed(seed, mappings) }.min
t2 = Time.now
delta_p1 = t2 - t1
puts "For part 1, the lowest location number is #{lowest_location} (calculated in #{delta_p1} seconds."


### PART 2 ###
def parse_seed_ranges(line)
  parts = line.split(':')[1].split.map(&:to_i)
  seed_ranges = parts.each_slice(2).map { |start, length| [start, start + length - 1] }
  seed_ranges.sort_by { |start, _| start }
end


def find_intersections(seed_range, mapping)
  #puts "Processing seed range: #{seed_range}"  # Debug print
  result = []
  start_point = seed_range.first

  mapping.each do |map_start, map_end, dest_start|
    #puts "Mapping range: map_start=#{map_start}, src_end=#{map_end}, dest_start=#{dest_start}"  # Debug print

    if start_point < map_start and seed_range.last >= map_start
      # Add the non-overlapping part before this mapping range
      result << [start_point, map_start - 1]
      #puts "Added non-overlapping before: [#{start_point}, #{map_start - 1}]"  # Debug print
    end

    overlap_start = [start_point, map_start].max
    overlap_end = [seed_range.last, map_end].min

    if overlap_start <= overlap_end
      # Add the overlapping part
      range_start = dest_start + overlap_start - map_start
      range_end = dest_start + overlap_end - map_start
      result << [range_start, range_end]
      #puts "Added overlapping: [#{range_start}, #{range_end}]"  # Debug print
      start_point = overlap_end + 1
    end
  end

  if start_point <= seed_range.last
    # Add the non-overlapping part after the last mapping range
    result << [start_point, seed_range.last]
    #puts "Added non-overlapping after: [#{start_point}, #{seed_range.last}]"  # Debug print
  end

  #puts "Final result for seed range #{seed_range}: #{result}"  # Debug print
  result
end

# mappings is an array of mappings for each stage, each mapping is an array of [map_start, src_end, dest_start]
seed_ranges = parse_seed_ranges(lines.first)
#puts "Seeds ranges: #{seed_ranges}"

#test_seed_range = [50, 90]
#test_mapping = [[50, 55, 101], [85, 90, 185]]

#result = find_intersections(test_seed_range, test_mapping)
#puts "Test result: #{result}"

def merge_overlapping_ranges(ranges)
  #puts "Input ranges for merging: #{ranges.inspect}"  # Debug print

  # Check if the ranges array is empty or not structured correctly
  return ranges if ranges.empty? || !ranges.all? { |range| range.is_a?(Array) && range.size == 2 }

  ranges.sort_by(&:first).reduce([]) do |merged, current|
    #puts "Merging: #{merged.inspect}, Current: #{current.inspect}"  # Debug print
    if merged.empty? || merged.last.last < current.first
      merged << current
    else
      merged.last[1] = [merged.last.last, current.last].max
    end
    merged
  end
end


def process_seed_ranges(seed_ranges, mappings)
  seed_ranges.flat_map do |seed_range|
    current_ranges = [seed_range]
    mappings.each do |_, mapping|
      next_ranges = []
      current_ranges.each do |current_range|
        intersected = find_intersections(current_range, mapping)
        next_ranges.concat(intersected)
      end
      current_ranges = merge_overlapping_ranges(next_ranges)
    end
    current_ranges
  end
end


def find_lowest_location_number(mapped_ranges)
  mapped_ranges.map { |range| range.first }.min
end

#categories = [:seed_to_soil_map, :soil_to_fertilizer_map, :fertilizer_to_water_map, :water_to_light_map, :light_to_temperature_map, :temperature_to_humidity_map, :humidity_to_location_map]
#mapped_ranges = seed_ranges.flat_map do |seed_range|
#category_mappings = categories.map { |category| mappings[category] }

# Apply mappings to seed ranges
final_mapped_ranges = process_seed_ranges(seed_ranges, mappings)

# Find the lowest location number
lowest_location_number = find_lowest_location_number(final_mapped_ranges)


t3 = Time.now
delta_p2 = t3 - t2
puts "For part 2, the lowest location number is #{lowest_location_number} (calculated in #{delta_p2} seconds."



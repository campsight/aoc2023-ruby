# Replace 'input.txt' with the path to your input file
input_file_path = 'data/day19.txt'

t1 = Time.now

# Read the input from the file
input_data = File.read(input_file_path)

def evaluate_condition(condition, ratings)
  return true if condition.nil?

  attribute, operator, value = condition.match(/(\w)([<>])(\d+)/).captures
  value = value.to_i


  result = operator == '>' && ratings[attribute] > value || operator == '<' && ratings[attribute] < value
  puts "Evaluating condition: #{condition}, Result: #{result}"
  result
end

# Parse workflows
parsed_workflows = {}
input_data.each_line do |line|
  next if line.strip.empty?

  line.strip!
  if line.include? '{' and not line.strip.start_with?('{')
    name, rules_str = line.split('{')
    rules = rules_str.chomp('}').split(',').map do |rule|
      condition, destination = rule.split(':')
      if destination == nil
        destination = condition
        condition = nil
      end
      { condition: condition, destination: destination }
    end
    parsed_workflows[name.strip] = rules
  end
end

t2 = Time.now
delta_p1 = t2 - t1
puts "Parsed Workflows: #{parsed_workflows.inspect} in #{delta_p1} s."


# Process each part
total = 0
input_data.each_line do |line|
  next unless line.strip.start_with?('{')

  # Parse the part's ratings
  ratings = line.scan(/(\w)=(\d+)/).to_h.transform_values(&:to_i)
  puts "\nProcessing Part: #{ratings}"

  # Start processing from the 'in' workflow
  current_workflow = 'in'
  loop do
    rules = parsed_workflows[current_workflow]
    rule_applied = false

    puts "Current workflow: #{current_workflow}, Rules: #{rules}"

    rules.each do |rule|
      condition, destination = rule[:condition], rule[:destination]
      puts "Evaluating Rule: Condition=#{condition}, Destination=#{destination}"


      if condition.nil? || evaluate_condition(condition, ratings)
        puts "Condition met or no condition. Destination: #{destination}"
        if destination == 'A'
          total += ratings.values.sum
          puts "Part accepted. Adding to total: #{total}"
          rule_applied = true
          break
        elsif destination == 'R'
          puts "Part rejected."
          rule_applied = true
          break
        else
          current_workflow = destination
          puts "Switching to workflow: #{current_workflow}"
          break
        end
      end
    end

    break if rule_applied
  end
end

puts total

### Part 2 ###
def rsize(ranges)
  # Assuming size function calculates the product of the sizes of the ranges
  ranges.values.reduce(1) { |product, range| product * (range[1] - range[0] + 1) }
end

def process_workflow(workflow_name, parsed_workflows, current_ranges)
  return unless parsed_workflows[workflow_name]
  result = 0
  parsed_workflows[workflow_name].each do |rule|
    condition, destination = rule[:condition], rule[:destination]

    if condition.nil?
      result += destination == "A" ? rsize(current_ranges) : process_workflow(destination, parsed_workflows, current_ranges) unless destination == "R"
    else
      attr, operator, value = parse_condition(condition)
      case operator
      when '>'
        new_ranges = Marshal.load(Marshal.dump(current_ranges))
        if new_ranges[attr][1] > value
          new_ranges[attr][0] = [new_ranges[attr][0], value + 1].max
          result += destination == "A" ? rsize(new_ranges) : process_workflow(destination, parsed_workflows, new_ranges) unless destination == "R"
          current_ranges[attr][1] = [current_ranges[attr][1], value].min
        end
      when '<'
        new_ranges = Marshal.load(Marshal.dump(current_ranges))
        if new_ranges[attr][0] < value
          new_ranges[attr][1] = [new_ranges[attr][1], value - 1].min
          result += destination == "A" ? rsize(new_ranges) : process_workflow(destination, parsed_workflows, new_ranges) unless destination == "R"
          current_ranges[attr][0] = [current_ranges[attr][0], value].max
        end
      end
    end
  end
  puts "Returning result #{result} for flow #{workflow_name} and range #{current_ranges}"
  result
end


def parse_condition(condition)
  attribute, operator, value = condition.match(/(\w)([<>])(\d+)/).captures
  [attribute, operator, value.to_i]
end


total_possibilities = process_workflow("in", parsed_workflows, {"x" => [1, 4000], "m" => [1, 4000], "a" => [1, 4000], "s" => [1, 4000]})
t3 = Time.now
delta_p2 = t3 - t2
puts "Total number of possibilities part 2: #{total_possibilities} in #{delta_p2} s."

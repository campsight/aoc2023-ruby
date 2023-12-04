def parse_game_data(file_path)
  File.read(file_path).split("\n").map do |line|
    game_id, subsets = line.split(': ')
    { id: game_id.split(' ').last.to_i, subsets: subsets.split('; ') }
  end
end

def game_possible?(game, red_limit, green_limit, blue_limit)
  game[:subsets].all? do |subset|
    red_count = subset.scan(/(\d+) red/).flatten.map(&:to_i).sum
    green_count = subset.scan(/(\d+) green/).flatten.map(&:to_i).sum
    blue_count = subset.scan(/(\d+) blue/).flatten.map(&:to_i).sum

    red_count <= red_limit && green_count <= green_limit && blue_count <= blue_limit
  end
end

# Path to your input file
file_path = 'data/day2_test.txt'

games = parse_game_data(file_path)
red_limit, green_limit, blue_limit = 12, 13, 14

possible_games = games.select { |game| game_possible?(game, red_limit, green_limit, blue_limit) }
sum_of_ids = possible_games.sum { |game| game[:id] }

puts "Sum of IDs of possible games: #{sum_of_ids}"


### Part 2 ###
def minimum_cubes_and_power(game)
  puts game
  max_red, max_green, max_blue = 0, 0, 0
  game[:subsets].each do | subset |
    red_count = subset.scan(/(\d+) red/).flatten.map(&:to_i).max || 0
    green_count = subset.scan(/(\d+) green/).flatten.map(&:to_i).max || 0
    blue_count = subset.scan(/(\d+) blue/).flatten.map(&:to_i).max || 0

    max_red = [max_red, red_count].max
    max_green = [max_green, green_count].max
    max_blue = [max_blue, blue_count].max
  end

  { red: max_red, green: max_green, blue: max_blue, power: max_red * max_green * max_blue }

end

games_with_min_cubes_and_power = games.map { |game| minimum_cubes_and_power(game) }
total_power = games_with_min_cubes_and_power.sum { |game| game[:power] }


puts "The sum of the total powers is: #{total_power}"
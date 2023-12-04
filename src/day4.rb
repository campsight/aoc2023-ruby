def parse_cards(file_path)
  File.readlines(file_path).map do |line|
    _, numbers_part = line.split(':')
    winning_numbers, your_numbers = numbers_part.split('|').map { |part| part.split.map(&:to_i) }
    { winning: winning_numbers, your: your_numbers }
  end
end

def calculate_card_points(card)
  matches = card[:your].count { |num| card[:winning].include?(num) }
  matches > 0 ? 2 ** (matches - 1) : 0
end

def total_points(cards)
  cards.sum { |card| calculate_card_points(card) }
end

# Replace 'path_to_your_input_file.txt' with the actual path to your input file
file_path = 'data/day4.txt'
cards = parse_cards(file_path)
total = total_points(cards)
puts "The total points are #{total}"


### PART 2 ###
def calculate_wins(cards)
  # Initialize an array with the number of copies for each card (1 for each original card)
  copies = Array.new(cards.length, 1)

  cards.each_with_index do |card, index|
    next unless copies[index] > 0 # Skip if no copies of this card

    matches = card[:your].count { |num| card[:winning].include?(num) }
    # Update the number of copies for subsequent cards
    (1..matches).each do |i|
      next_index = index + i
      copies[next_index] += copies[index] if next_index < cards.length
    end
  end

  copies.sum
end

total = calculate_wins(cards)
puts "The total number of scratchcards is #{total}"

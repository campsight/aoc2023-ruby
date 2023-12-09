def parse_input(file_path)
  hands = File.readlines(file_path).map do |line|
    hand, bid = line.split
    [hand, bid.to_i]
  end
end

CARD_ORDER = "AKQJT98765432"

def hand_strength(hand)
  counts = hand.chars.tally
  case counts.values.max
  when 5
    :five_of_a_kind
  when 4
    :four_of_a_kind
  when 3
    counts.values.include?(2) ? :full_house : :three_of_a_kind
  when 2
    counts.values.count(2) == 2 ? :two_pair : :one_pair
  else
    :high_card
  end
end

HAND_STRENGTHS = {
  five_of_a_kind: 7,
  four_of_a_kind: 6,
  full_house: 5,
  three_of_a_kind: 4,
  two_pair: 3,
  one_pair: 2,
  high_card: 1
}

def hand_strength_value(hand)
  HAND_STRENGTHS[hand_strength(hand)]
end

def compare_cards(card1, card2)
  CARD_ORDER.index(card1) <=> CARD_ORDER.index(card2)
end

def compare_hands(hand1, hand2)
  strength1, strength2 = [hand1, hand2].map { |hand| hand_strength_value(hand) }
  return strength1 <=> strength2 if strength1 != strength2

  # Sort cards in each hand in descending order of their strength
  #sorted_hand1 = hand1.chars.sort_by { |card| CARD_ORDER.index(card) }
  #sorted_hand2 = hand2.chars.sort_by { |card| CARD_ORDER.index(card) }

  # Compare card by card without sorting, in the order they are given
  hand1.chars.zip(hand2.chars).each do |card1, card2|
    card_comparison = compare_cards(card1, card2)
    return -card_comparison unless card_comparison == 0
  end

  0  # If all cards are equal, the hands are equal
end


def total_winnings(file_path)
  hands = parse_input(file_path)

  # Sort hands based on their strength and card ranks
  sorted_hands = hands.sort do |a, b|
    compare_hands(a.first, b.first)
  end

  sorted_hands.each_with_index.sum do |(hand, bid), index|
    rank = index + 1  # Rank is index + 1 because index starts at 0
    bid * rank
  end
end



file_path = 'data/day7.txt'  # Replace with your actual file path
winnings = total_winnings(file_path)
puts "Total winnings: #{winnings}"


### PART 2 ###

CARD_ORDER2 = "AKQT98765432J"

def hand_strength2(hand)
  return :five_of_a_kind if hand == 'JJJJJ'

  counts = hand.gsub('J', '').chars.tally
  joker_count = hand.count('J')

  # Check for Five of a Kind or Four of a Kind
  if counts.any? { |_, count| count + joker_count == 5 }
    return :five_of_a_kind
  elsif counts.any? { |_, count| count + joker_count == 4 }
    return :four_of_a_kind
  end

  # Check for Full House
  three_count = counts.select { |_, count| count == 3 }.length
  pair_count = counts.select { |_, count| count == 2 }.length
  single_count = counts.select { |_, count| count == 1 }.length

  if joker_count > 0
    if (three_count > 0) || (pair_count == 2) || (pair_count == 1 && joker_count >= 2)
      return :full_house
    end
  else
    return :full_house if counts.values.sort == [2, 3]
  end

  # Check for Three of a Kind
  if counts.any? { |_, count| count + joker_count >= 3 }
    return :three_of_a_kind
  end

  # Check for Two Pair
  if counts.values.count(2) >= 2 || (counts.values.count(2) == 1 && joker_count >= 1)
    return :two_pair
  end

  # Check for One Pair
  if counts.values.count(2) >= 1 || (joker_count >= 1 && counts.values.count(1) >= 1)
    return :one_pair
  end

  # Default to High Card
  :high_card
end


def hand_strength_value2(hand)
  HAND_STRENGTHS[hand_strength2(hand)]
end

def compare_cards2(card1, card2)
  CARD_ORDER2.index(card1) <=> CARD_ORDER2.index(card2)
end

def compare_hands2(hand1, hand2)
  strength1, strength2 = [hand1, hand2].map { |hand| hand_strength_value2(hand) }
  return strength1 <=> strength2 if strength1 != strength2

  # Compare card by card without sorting, in the order they are given
  hand1.chars.zip(hand2.chars).each do |card1, card2|
    card_comparison = compare_cards2(card1, card2)
    return -card_comparison unless card_comparison == 0
  end

  0  # If all cards are equal, the hands are equal
end


def total_winnings2(file_path)
  hands = parse_input(file_path)

  # Sort hands based on their strength and card ranks
  sorted_hands = hands.sort do |a, b|
    compare_hands2(a.first, b.first)
  end

  sorted_hands.each_with_index.sum do |(hand, bid), index|
    rank = index + 1  # Rank is index + 1 because index starts at 0
    #puts "Hand: #{hand}, Bid: #{bid}, Rank: #{rank}"  # Debug print
    bid * rank
  end
end

winnings2 = total_winnings2(file_path)
puts "Total winnings Part 2: #{winnings2}"
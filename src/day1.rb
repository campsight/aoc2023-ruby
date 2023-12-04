def read_input(file)
  File.readlines(file).map(&:chomp)
end

def find_calibration_sum(input)
  input.sum do |line|
    digits = line.scan(/\d/).map(&:to_i)
    next 0 if digits.empty?

    first_digit = digits.first
    last_digit = digits.last
    (first_digit.to_s + last_digit.to_s).to_i
  end
end

# Assuming the input is in a file called 'calibration_input.txt'
input = read_input('data/day1.txt')
calibration_sum = find_calibration_sum(input)

puts "The sum of all calibration values is #{calibration_sum}."


### PART 2 ###
def find_calibration_sum2(input)
  digit_words = {
    'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4',
    'five' => '5', 'six' => '6', 'seven' => '7', 'eight' => '8', 'nine' => '9'
  }
  digit_word_regex = Regexp.new('\\A(?:' + digit_words.keys.join('|') + ')')

  input.sum do |line|
    digits = []
    idx = 0

    while idx < line.length
      # Check for a spelled-out digit word
      if line[idx..].match?(digit_word_regex)
        word = line[idx..].match(digit_word_regex)[0]
        digits << digit_words[word]
        idx += (word.length - 1) # Move past this digit word
      elsif line[idx].match?(/\d/)
        digits << line[idx]
        idx += 1 # Move to the next character
      else
        idx += 1 # Move to the next character
      end
    end

    next 0 if digits.empty?

    # Combine first and last digits
    (digits.first + digits.last).to_i
  end
end


calibration_sum2 = find_calibration_sum2(input)

puts "For part 2, the sum of all calibration values is #{calibration_sum2}."
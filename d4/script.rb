# Parse input to arrays

file = File.open("input.txt")
chosen_numbers = file.readline.split(',').map(&:to_i)
file.readline
array = file.readlines

players = []

i = 0
num_players = (array.length + 1) / 6
while i < num_players * 6
  player = array[i..i + 4].map do |e|
    e.split(" ").map(&:to_i)
  end
  players.push(player)
  i += 6
end

# Check conditions of win

def check_lines(player)
  check = false
  player.each do |line|
    if line.sum == -5
      check = true
      break
    end
  end
  check
end

def check_columns(player)
  check = false
  [*0..4].each do |j|
    sum = 0
    [*0..4].each do |i|
      sum += player[i][j]
    end
    if sum == -5
      check = true
      break
    end
  end
  check
end

def win?(player)
  check_lines(player) || check_columns(player)
end

# replace all "chosen number" of board by -1

def update_player(player, number)
  player.each_with_index.map do |line, i|
    line.map do |e|
      e == number ? -1 : e
    end
  end
end

# Score

def calcul(player, number)
  sum = 0
  player.each do |line|
    line.each do |e|
      sum += (e == -1 ? 0 : e)
    end
  end
  sum * number
end

# Part 1

def play(players, numbers)
  has_winner = false
  numbers.each do |number|
    players.each_with_index do |player, i|
      new_player = update_player(player, number)
      players[i] = new_player
      if win?(new_player)
        has_winner = true
        puts number
        puts new_player
        puts calcul(new_player, number)
        break
      end
    end
    break if has_winner
  end
end

# play(players, chosen_numbers) # Solution Part 1

# Part 2

def play_2(players, numbers)
  numbers.each do |number|
    last_winners = []
    players.each_with_index do |player, i|
      new_player = update_player(player, number)
      players[i] = new_player
      next unless win?(new_player)

      last_winners.push(i)
      puts '----'
      puts number
      puts calcul(new_player, number)
    end
    players.delete_if.with_index { |_, i| last_winners.include? i }
  end
end

# play_2(players, chosen_numbers)

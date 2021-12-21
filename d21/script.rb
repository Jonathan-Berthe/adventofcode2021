## INPUT

start1 = 9
start2 = 6

## Part 1

scores = [0, 0]
positions = [start1, start2]
current_player = 0
count = 0
loop do
  forward = 3 * (count + 1) + 3
  positions[current_player] = (positions[current_player] + forward - 1) % 10 + 1
  scores[current_player] += positions[current_player]
  count += 3
  break if scores[current_player] >= 1000

  current_player = current_player == 1 ? 0 : 1
end

p current_player # Winner
looser = current_player == 1 ? 0 : 1
p count * scores[looser] # Solution part 1

## Part 2

# After each step => forward of [3,4,5,6,7,8,9], depending of the sum of the 3 dices rolls
# => In 3 dice rolls, we create 3^3 = 27 new universes.
# We want to compute the repartition of these 27 universes, so in how many universes among these 27 we'll have 3 as sum, or 4, or 5...

rolls_sum_repartition = Array.new(7, 0)
[*1..3].each do |d1|
  [*1..3].each do |d2|
    [*1..3].each do |d3|
      sum = d1 + d2 + d3
      rolls_sum_repartition[sum - 3] += 1
    end
  end
end
p rolls_sum_repartition # [1, 3, 6, 7, 6, 3, 1]

$max_of_steps = 20 # Hypothesis: can't have more than 20 steps to have a winner (works for this input)

class Player
  attr_reader :all_universes, :numbers_of_wins_by_steps, :numbers_of_loose_by_steps 

  def initialize(start, rolls_sum_repartition)
    @start = start
    @rolls_sum_repartition = rolls_sum_repartition

    # In @all_universes, we'll stack all the possible "universe" sets for the player, with a universe set define as [[s1,...,sn], score, position, cardinality]. ie: [[3,6,7], 14, 2, 2048] is the set of all universes (2048 universes in total) which have a suite of successive dice rolls sum of 3,6,7 and this suite correspond to a score of 14 and a position of 2 for the player
    @all_universes = []

    # @numbers_of_wins_by_steps[i] = numbers of universe where player wins after i + 1 steps
    @numbers_of_wins_by_steps = Array.new($max_of_steps, 0)
    # @numbers_of_wins_by_steps[i] = numbers of universe where player wins after i + 1 steps
    @numbers_of_loose_by_steps  = Array.new($max_of_steps, 0)
  end

  # "paths" for the suite of the 3 dice rolls sum
  def recursive_all_winners_paths(previous_universe)
    previous_rolls = previous_universe[0]
    previous_score = previous_universe[1]
    previous_position = previous_universe[2]
    previous_cardinality = previous_universe[3]
    # loop in all possible sum that occur in the new step of the path
    [*3..9].each do |total_roll|
      new_rolls = [*previous_rolls, total_roll]
      new_position = (previous_position + total_roll - 1) % 10 + 1
      new_score = previous_score + new_position
      new_cardinality = previous_cardinality * @rolls_sum_repartition[total_roll - 3]
      new_universe = [new_rolls, new_score, new_position, new_cardinality]
      @all_universes.push(new_universe)
      if new_score >= 21
        @numbers_of_wins_by_steps[new_rolls.length - 1] += new_cardinality
        next
      else
        numbers_of_loose_by_steps[new_rolls.length - 1] += new_cardinality
        recursive_all_winners_paths(new_universe)
      end
    end
  end

  def run
    initial_universe = [[], 0, @start, 1]
    recursive_all_winners_paths(initial_universe)
  end
end

# Set players
player1 = Player.new(start1, rolls_sum_repartition)
player1.run
player2 = Player.new(start2, rolls_sum_repartition)
player2.run

wins1 = 0 # number of win player 1
wins2 = 0 # number of win player 2

# We'll compute the number of win for each player for all universe with suite of i steps, and sum for all steps to have the total of "winning" universes for each player
[*0..$max_of_steps - 1].each do |i|
  # Wins of player 1
  wins_p1_in_i_steps = player1.numbers_of_wins_by_steps[i]
  loose_p2_in_previous_steps = i.positive? ? player2.numbers_of_loose_by_steps[i - 1] : 1
  wins1 += wins_p1_in_i_steps * loose_p2_in_previous_steps

  # Wins of player 2
  win_p2_in_i_steps = player2.numbers_of_wins_by_steps[i]
  loose_p1_in_i_steps = player1.numbers_of_loose_by_steps[i]
  wins2 += win_p2_in_i_steps * loose_p1_in_i_steps
end
p wins1
p wins2
p [wins1, wins2].max # Solution part 2

# Parsing input 
file = File.open("input.txt")
array = file.readlines.map do |line|
  line.gsub("\n",'').split("").map do |e|
    case e
    when "#"
      nil
    when "."
      0
    when "A"
      1
    when "B"
      2
    when "C"
      3
    when "D"
      4
    else
      raise "error"
    end
  end
end

# A game config is the object representing the "node" in the path we try to minimize with dijkstra algo
class GameConfig
  attr_reader :cost, :state, :step, :has_best
  attr_accessor :d

  def initialize(array, cost, step, part2)
    @d = Float::INFINITY # for dijkstra algo
    @state = array # current state of the game
    @cost = cost
    @step = step
    @has_best = nil
    @part2 = part2 # boolean to know if we are in the part1 or part2 of the problem
  end

  # return array of all possible GameConfig, or an array with the "best" GameConfig if we have some
  def all_game_config_for_next_step
    @has_best = nil
    accum = []
    @state.each_with_index do |line, i|
      line.each_with_index do |e, j|
        next if e.nil? || e.zero?

        # all the possibles next points positions for this amphipod
        possible_points = all_possible_next_points(i, j)
        possible_points.each do |point|
          x, y, tmp_cost = point
          copy_state = @state.dup.map(&:dup)
          copy_state[i][j] = 0
          copy_state[x][y] = e
          next_game = GameConfig.new(copy_state, tmp_cost, @step + 1, @part2)

          # If the current point correspond to the amphipod in his room => it's the best choice of the step !
          if corresponding_room(i, j) == y
            accum = [next_game]
            @has_best = true
            break
          end

          accum.push(next_game)
        end
        break if @has_best
      end
      break if @has_best
    end
    if @has_best
      return accum
    else
      tmp = []
      # The idea here is to restrict the possible choices for next step to the one which have a "best" choice in 2 steps. It's an hyphothesis i made to improve computing time, and the solution as been found with this :)
      accum.each do |game|
        game.all_game_config_for_next_step
        if game.has_best
          tmp.push(game)
        end
      end
      accum = tmp unless tmp.empty?
      accum = accum.sort_by { |game| game.cost }
      return accum
    end
    accum
  end

  def entrance?(i, j)
    @state[i - 1][j].nil? && !@state[i + 1][j].nil?
  end

  # return column of the room of the amphipod positioning in (i,j)
  def corresponding_room(i,j)
    case @state[i][j]
    when 1
      3
    when 2
      5
    when 3
      7
    when 4
      9
    else
      -1 # Not a antip
    end
  end

  # Check if it's the final state with all the amphipods in their rooms
  def end?
    interval = @part2 ? [*2..5] : [*2..3]
    check = true
    interval.each do |i|
      unless @state[i][3] == 1 && @state[i][5] == 2 && @state[i][7] == 3 && @state[i][9] == 4
        check = false
        break
      end
    end
    check
  end

  # Check if an amphipod can access the room at column in the next step
  def room_is_available?(column)
    interval = @part2 ? [*2..5] : [*2..3]
    check = true
    interval.each do |i|
      room = @state[i][column]
      if !room.zero? && corresponding_room(i, column) != column
        check = false
        break
      end
    end
    check
  end

  # For a given amphipod (i,j), return all the possible points for him in the next step
  def all_possible_next_points(i, j)
    raise "not a amphi" if @state[i][j].zero? || @state[i][j].nil?

    type = @state[i][j]
    accum = []
    cost = 0
    x, y = i, j

    if (corresponding_room(i,j) == j)
      check = true
      max = @part2 ? 5 : 3
      [*i + 1..max].each do |i2|
        if @state[i2][j] != @state[i][j]
          check = false
          break
        end
      end
      return [] if check
    end

    if i != 1 # We are in a room
      ## Go up
      while !@state[x - 1][y].nil? && @state[x - 1][y].zero?
        x = x - 1
        cost += 10 ** (type - 1)
      end
      tmp_cost = cost
      ## To the left or to the right:
      # => to the left
      while !@state[x][y - 1].nil? && @state[x][y - 1].zero?
        y = y - 1
        cost += 10 ** (type - 1)
        accum.push([x, y, cost]) unless entrance?(x, y)
        # And go down...
        if entrance?(x, y) && corresponding_room(i,j) == y && room_is_available?(y)
          while !@state[x + 1][y].nil? && @state[x + 1][y].zero?
            x = x + 1
            cost += 10 ** (type - 1)
          end
          accum = [[x, y, cost]]
          return accum
          break
        end
      end
      # => To the right
      cost = tmp_cost
      y = j
      while !@state[x][y + 1].nil? &&  @state[x][y + 1].zero?
        y = y + 1
        cost += 10 ** (type - 1)
        accum.push([x, y, cost]) unless entrance?(x, y)
        # And go down...
        if entrance?(x, y) && corresponding_room(i,j) == y && room_is_available?(y)
          while !@state[x + 1][y].nil? && @state[x + 1][y].zero?
            x = x + 1
            cost += 10 ** (type - 1)
          end
          accum = [[x, y, cost]]
          return accum
          break
        end
      end

    else # Not in a room
      # => to the left
      while !@state[x][y - 1].nil? &&  @state[x][y - 1].zero?
        y = y - 1
        cost += 10 ** (type - 1)
        # And go down...
        if entrance?(x, y) && corresponding_room(i,j) == y && room_is_available?(y)
          while !@state[x + 1][y].nil? && @state[x + 1][y].zero?
            x = x + 1
            cost += 10 ** (type - 1)
          end
          accum = [[x, y, cost]]
          return accum
          break
        end
      end
      cost = 0
      # => to the right
      y = j
      while !@state[x][y + 1].nil? && @state[x][y + 1].zero?
        y = y + 1
        cost += 10 ** (type - 1)
        # And go down...
        if entrance?(x, y) && corresponding_room(i,j) == y && room_is_available?(y)
          while !@state[x + 1][y].nil? && @state[x + 1][y].zero?
            x = x + 1
            cost += 10 ** (type - 1)
          end
          accum = [[x, y, cost]]
          return accum
          break
        end
      end
    end
    accum
  end
end

part2 = array.length == 7
game = GameConfig.new(array, 0, 0, part2)

def djikstra(sdeb)
  queue = [sdeb]
  a = sdeb
  a.d = 0
  while !a.end?
    voisins = a.all_game_config_for_next_step
    voisins.each do |voisin|
      voisin.d = a.d + voisin.cost
      if voisin.step < 200 # Hyp: we have a max number of step in our optimal solution
        similar_game_index = queue.find_index { |game| game.state == voisin.state }
        if !similar_game_index.nil?
          similar_game = queue[similar_game_index]
          if voisin.d < similar_game.d
            queue[similar_game_index] = voisin
          end
        else
          queue.push(voisin)
        end
      end
    end
    queue.delete(a)
    queue = queue.sort_by(&:d)
    a = queue.min { |m, b| m.d <=> b.d }
    break if a.end?
  end
  a
end

final = djikstra(game)
p final.state
p final.d

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




class Game
  attr_reader :cost, :state, :d, :step, :previousState, :has_best

  def initialize(array, cost, step, previousState)
    @d = Float::INFINITY
    @state = array
    @cost = cost
    @step = step
    @all_next_steps = []
    @previousState = previousState
    @has_best = nil
  end

  def set_d(value)
    @d = value
  end

  def all_possible_next_steps2
    @has_best = nil
    accum = []
    @state.each_with_index do |line, i|
      line.each_with_index do |e, j|
        next if e.nil? || e.zero?

        possible_points = all_possible_next_points(i, j) 
        possible_points.each do |point|
          x, y, tmp_cost = point        
          copy_state = @state.dup.map{ |line| line.dup }
          copy_state[i][j] = 0
          copy_state[x][y] = e
          next_game = Game.new(copy_state, tmp_cost, @step + 1, self)

          if corresponding_room(i,j) == y
            accum = [next_game]
            @has_best = true
            break
          end

          #next_game.all_possible_next_steps2
          #if !@has_best && next_game.has_best
          #  p "lalalalalala"
          #  accum = [next_game]
          #  p accum
          #  return accum
          #end
          
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
      accum.each do |game|
        game.all_possible_next_steps2
        if game.has_best
          tmp.push(game)
          #accum = [game]
          #break
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

  def end? # TO CHANGE
    @state[2][3] == 1 && @state[3][3] == 1 && @state[2][5] == 2 && @state[3][5] == 2 && @state[2][7] == 3 && @state[3][7] == 3 && @state[2][9] == 4 && @state[3][9] == 4
  end

  def room_is_available?(column)
    v1 = @state[2][column]
    v2 = @state[3][column]
    return true if v1.zero? && v2.zero?
    if (!v1.zero? && corresponding_room(2, column) != column) || (!v2.zero? && corresponding_room(3, column) != column)
      return false
    else
      true
    end
  end

  def all_possible_next_points(i, j)
    raise "not a amphi" if @state[i][j].zero? || @state[i][j].nil?

    type = @state[i][j]
    accum = []
    cost = 0
    x, y = i, j

    if (corresponding_room(i,j) == j)
      check = true
      [*i + 1..3].each do |i2| # !!!!! changer 3 en 5 pour step 2
        if @state[i2][j] != @state[i][j]
          check = false
          break
        end
      end
      return [] if check
    end

    if i != 1 # On peut monter puis aller a droite à gauche
      ## On monte
      while !@state[x - 1][y].nil? && @state[x - 1][y].zero?
        x = x - 1
        cost += 10 ** (type - 1)
        #accum.push([x, y, cost]) unless entrance?(x, y) # A mettre ?
      end
      tmp_cost = cost
      ## On va a droite ou gauche
      # => A gauche
      while !@state[x][y - 1].nil? && @state[x][y - 1].zero?
        y = y - 1
        cost += 10 ** (type - 1)
        accum.push([x, y, cost]) unless entrance?(x, y)
        # Et on redescend...
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
      # => A droite
      cost = tmp_cost
      y = j
      while !@state[x][y + 1].nil? &&  @state[x][y + 1].zero?
        y = y + 1
        cost += 10 ** (type - 1)
        accum.push([x, y, cost]) unless entrance?(x, y)
        # Et on redescend...
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

    else # On aller à droite à gauche PUIS descendre si on peut rentrer dans la room
      # => A gauche
      while !@state[x][y - 1].nil? &&  @state[x][y - 1].zero?
        y = y - 1
        cost += 10 ** (type - 1)
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
      # => A droite
      y = j
      while !@state[x][y + 1].nil? && @state[x][y + 1].zero?
        y = y + 1
        cost += 10 ** (type - 1)
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

game = Game.new(array, 0, 0, nil)

def djikstra(sdeb)
  queue = [sdeb]
  all_states = queue.map(&:state)
  a = sdeb
  a.set_d(0)
  while !a.end?
    #p "step"
    p queue.length
    voisins = a.all_possible_next_steps2
    #p voisins.length
    #p voisins
    voisins.each do |voisin|
      voisin.set_d(a.d + voisin.cost)
      if voisin.step < 20
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

      #queue.push(voisin) unless voisin.step > 20
    end
    queue.delete(a)
    a = queue.min { |a, b| a.d <=> b.d }
    #break
    break if a.end?
    #a = voisins[0]
    #break
  end
  a
end

final = djikstra(game)

p final.state

p final.d
# p array
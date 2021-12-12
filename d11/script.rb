class Octopus
  def initialize(init_state)
    @m = init_state.length
    @n = init_state[0].length
    @state = init_state
  end

  def neighbours(pos_i, pos_j)
    out = []
    [*-1..1].each do |i|
      [*-1..1].each do |j|
        x = pos_i + i
        y = pos_j + j
        next if (x == pos_i && y == pos_j) || x < 0 || x > @m - 1 || y < 0 || y > @n - 1 
        out.push([pos_i + i, pos_j + j])
      end
    end
    out
  end

  # octopus in (pos_i, pos_j) explode !
  def explode(pos_i, pos_j)
    @state[pos_i][pos_j] = 0
    neighbours(pos_i, pos_j).each do |pos|
      energy_neighbour = @state[pos[0]][pos[1]]
      if energy_neighbour >= 9
        explode(pos[0], pos[1])
      elsif energy_neighbour != 0
        @state[pos[0]][pos[1]] = energy_neighbour + 1
      end
    end
  end

  # energy => energy + 1
  def phase1
    @state = @state.map do |line|
      line.map do |e|
        e = e + 1
      end
    end
  end

  # Exploding phase
  def phase2
    @state.each_with_index do |line, pos_i|
      line.each_with_index do |e, pos_j|
        explode(pos_i, pos_j) if e == 10
      end
    end
  end

  def nbr_flashs
    count = 0
    @state.each do |line|
      line.each do |e|
        count += 1 if e == 0
      end
    end
    count
  end

  # run - Part 1
  def run1(steps)
    count = 0
    steps.times do
      phase1
      phase2
      count += nbr_flashs
    end
    count
  end

  # run - Part 2
  def run2
    count_step = 0
    while nbr_flashs < @m * @n
      phase1
      phase2
      count_step += 1
    end
    count_step
  end
end

file = File.open("dummy.txt")
array = file.readlines.map { |line| line.gsub("\n","") }.map { |line| line.split("").map(&:to_i) }

octopus = Octopus.new(array)
# p octopus.run1(100) # Part 1
p octopus.run2 # Part 2

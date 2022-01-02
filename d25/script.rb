# Parse input

file = File.open('input.txt')
array = file.readlines.map do |line|
  line.gsub("\n", '').split('')
end

class SeaFloor
  def initialize(init_state)
    @state = init_state
    @m = @state.length
    @n = @state[0].length
  end

  def process
    count = 1
    until stable?
      step
      count += 1
    end
    count
  end

  def step
    # Step 1
    copy_state = @state.dup.map(&:dup)
    [*0..@m - 1].each do |i|
      [*0..@n - 1].each do |j|
        next unless east?(i, j)

        next if neighbour?(i, j)

        copy_state[i][j] = '.'
        copy_state[i][(j + 1) % @n] = '>'
      end
    end
    @state = copy_state.dup.map(&:dup)

    # Step 2
    [*0..@m - 1].each do |i|
      [*0..@n - 1].each do |j|
        next unless south?(i, j)

        next if neighbour?(i, j)

        copy_state[i][j] = '.'
        copy_state[(i + 1) % @m][j] = 'v'
      end
    end

    @state = copy_state.dup.map(&:dup)
  end

  def east?(i, j)
    @state[i][j] == '>'
  end

  def south?(i, j)
    @state[i][j] == 'v'
  end

  def empty_loc?(i, j)
    @state[i][j] == '.'
  end

  def neighbour?(i,j)
    raise 'empty loc' if empty_loc?(i, j)

    neigh = south?(i, j) ? @state[(i + 1) % @m][j] : @state[i][(j + 1) % @n]
    neigh != '.'
  end

  def stable?
    check = true
    [*0..@m - 1].each do |i|
      [*0..@n - 1].each do |j|
        next unless south?(i, j) || east?(i, j)

        unless neighbour?(i,j)
          check = false
          break
        end
      end
      break unless check
    end
    check
  end
end

sea_floor = SeaFloor.new(array)
# Solution
p sea_floor.process

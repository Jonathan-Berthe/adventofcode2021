# Read and parse input

file = File.open('dummy3.txt')
array = file.readlines.map do |line|
  line.gsub("\n", '').split(' ').map.with_index do |line_array, i|
    if i.zero?
      line_array == 'on' ? 1 : 0
    else
      line_array.split(',').map do |elem|
        elem[2..elem.length - 1].split('..').map(&:to_i)
      end
    end
  end
end



class StepProc
  attr_reader :x_min, :x_max, :y_min, :y_max, :turn, :interval

  def initialize(array)
    @turn = array[0]
    @interval = array[1]
    @x_min, @x_max = array[1][0]
    @y_min, @y_max = array[1][1]
  end

  def turn_on?
    @turn == 1
  end

  def turn_off?
    @turn.zero?
  end
end

all_procs = array.map { |line| StepProc.new(line) }
#p all_procs.map(&:interval)


class Reactor
  def initialize(all_procs, bound)
    @bound = bound
    grid_size = 2 * bound + 1
    @state_2d = Array.new(grid_size) { Array.new(grid_size, 0) }
    @all_procs = all_procs

    all_procs.each do |proc|
      apply_proc(proc)
    end
  end

  def set_cube(x, y, value)
    @state_2d[x + @bound][y + @bound] = value
  end

  def cube(x, y)
    @state_2d[x + @bound][y + @bound]
  end

  def count_on
    count = 0
    @state_2d.each do |dim1|
      dim1.each do |value|
        count += 1 if value == 1
      end
    end
    count
  end

  def apply_proc(proc)
    [*proc.x_min..proc.x_max].each do |x|
      [*proc.y_min..proc.y_max].each do |y|
        set_cube(x, y, proc.turn)
      end
    end
  end
end

reactor = Reactor.new(all_procs, 50)
p reactor.count_on
#raise "e"

class GridSet # Set define as all union of intervals in array_intervals
  attr_reader :array_intervals

  def initialize(array_intervals)
    @array_intervals = array_intervals
  end

  def compute_card
    n = array_intervals.length
    card = 0
    [*0..n - 1].each do |k|
      sum = 0
      all_combinations = array_intervals.combination(k + 1).to_a
      all_combinations.each do |combination|
        sum += inter_intervals_card(combination)
      end
      card += (-1)**k * sum
    end
    card
  end

  def add(interval)
    @array_intervals.push(interval)
  end

  def remove2(interval_to_remove)
    intervals_to_add = []
    intervals_to_delete = []
    @array_intervals.each do |interval|

      # Find intersection
      intersection = intersection_2d(interval, interval_to_remove)

      next if intersection.nil?

      interval1_x, interval1_y = interval
      interval2_x, interval2_y = intersection

      x_array = [*interval1_x, *interval2_x].uniq.sort
      y_array = [*interval1_y, *interval2_y].uniq.sort
      [*0..x_array.length - 2].map do |ix|
        [*0..y_array.length - 2].map do |iy|
          x_min = x_array[ix]
          x_max = x_array[ix + 1]
          y_min = y_array[iy]
          y_max = y_array[iy + 1]

          new_interval = [[x_min, x_max], [y_min, y_max]]
          next if new_interval == intersection

          intervals_to_add.push(new_interval)
        end
      end

      # On ajoute l'intersection entre tous les côté d'interval_to_remove et de interval
      interval_x, interval_y = interval_to_remove

      interval_x.each do |x|
        border_interval = [[x, x], interval_y]
        new_interval =  intersection_2d(interval, border_interval)
        intervals_to_add.push(new_interval)
      end
      interval_y.each do |y|
        border_interval = [interval_x, [y, y]]
        new_interval =  intersection_2d(interval, border_interval)
        intervals_to_add.push(new_interval)
      end

      intervals_to_delete.push(interval)
      intervals_to_add = simplify(intervals_to_add)
    end
    intervals_to_delete.each do |e|
      @array_intervals.delete(e)
    end

    #intervals_to_add = simplify(intervals_to_add)
    intervals_to_add.each do |e|
      @array_intervals.push(e)
    end
  end

  def self_simplify
    @array_intervals = simplify(@array_intervals)
  end

  def simplify(intervals)
    copy = intervals.map(&:dup)
    [*0..intervals.length - 2].each do |i|
      [*1..intervals.length - 1].each do |j|
        next if i == j

        union = union(copy[i], copy[j])
        next if union.nil?
        copy[i] = union
        copy[j] = nil
      end
    end
    copy.compact
  end

  def is_single_point?(interval)
    interval_x, interval_y, interval_z = interval

    interval_x[0] == interval_x[1] && interval_y[0] == interval_y[1]
  end


  def voisins?(interval_point1, interval_point2)
    interval1_x, interval1_y = interval_point1
    interval2_x, interval2_y = interval_point2

    (interval1_x == interval2_x && (interval1_y[0] - interval2_y[0]).abs == 1) || (interval1_y == interval2_y && (interval1_x[0] - interval2_x[0]).abs == 1)
  end

  def union(interval1, interval2)
    return nil if interval1.nil? || interval2.nil? || intersection_2d(interval1, interval2).nil?

    #if intersection_3d(interval1, interval2).nil? && !(is_single_point?(interval1) && is_single_point?(interval2) && voisins?(interval1, interval2))
      #return nil
    #end

    interval1_x, interval1_y = interval1
    interval2_x, interval2_y = interval2

    if interval1_x == interval2_x
      interval_y = [[*interval1_y, *interval2_y].min, [*interval1_y, *interval2_y].max]
      return [interval1_x, interval_y]
    elsif interval1_y == interval2_y
      interval_x = [[*interval1_x, *interval2_x].min, [*interval1_x, *interval2_x].max]
      return [interval_x, interval1_y]
    elsif is_include_in_other_interval_2d?(interval1, interval2)
      return interval2
    elsif is_include_in_other_interval_2d?(interval2, interval1)
      return interval1
    end
    nil
  end

  def in_interval_1d?(x, interval)
    x_min = interval.min
    x_max = interval.max
    x <= x_max && x >= x_min
  end

  def is_include_in_other_interval_1d?(interval, other_interval)
    x_min = interval.min
    x_max = interval.max
    in_interval_1d?(x_min, other_interval) && in_interval_1d?(x_max, other_interval)
  end

  def is_include_in_other_interval_2d?(interval, other_interval)
    interval1_x, interval1_y = interval
    interval2_x, interval2_y = other_interval
    is_include_in_other_interval_1d?(interval1_x, interval2_x) && is_include_in_other_interval_1d?(interval1_y, interval2_y)
  end

  def intersection_1d(interval1, interval2)
    x_min1 = interval1.min
    x_max1 = interval1.max
    x_min2 = interval2.min
    x_max2 = interval2.max
    if in_interval_1d?(x_min1, interval2) && in_interval_1d?(x_max1, interval2)
      interval1
    elsif in_interval_1d?(x_min2, interval1) && in_interval_1d?(x_max2, interval1)
      interval2
    elsif in_interval_1d?(x_min1, interval2) #&& x_min1 != x_max2
      [x_min1, x_max2]
    elsif in_interval_1d?(x_max1, interval2) #&& x_min2 != x_max1
      [x_min2, x_max1]
    else
      nil
    end
  end

  def intersection_2d(interval1, interval2)
    interval1_x, interval1_y = interval1
    interval2_x, interval2_y = interval2
    intersection_x = intersection_1d(interval1_x, interval2_x)
    intersection_y = intersection_1d(interval1_y, interval2_y)
    if intersection_x.nil? || intersection_y.nil?
      nil
    else
      [intersection_x, intersection_y]
    end
  end

  def interval_card(interval)
    interval_x, interval_y = interval
    (interval_x.max - interval_x.min + 1) * (interval_y.max - interval_y.min + 1)
  end

  def inter_intervals_card(array)
    tmp = array[0]
    [*1..array.length - 1].each do |i|
      intersection = intersection_2d(tmp, array[i])
      return 0 if intersection.nil?

      tmp = intersection
    end
    interval_card(tmp)
  end
end

init_set = [all_procs[0].interval]
reactor = GridSet.new(init_set)
 
[*1..all_procs.length - 1].each do |i|
  #p "new proc"
  #p i
  reactor.add(all_procs[i].interval) if all_procs[i].turn_on?
  if all_procs[i].turn_off?
    interval_x, interval_y = all_procs[i].interval
    new_interval = [[interval_x[0] - 1, interval_x[1] + 1], [interval_y[0] - 1, interval_y[1] + 1]]
    reactor.remove2(new_interval)
  end
  reactor.self_simplify
end

p reactor.array_intervals
p "plop"
#p reactor.array_intervals.map { |interval| reactor.interval_card(interval) }.sum
p reactor.compute_card
p "la"
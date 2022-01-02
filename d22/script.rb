# Read and parse input

file = File.open('input.txt')
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
  attr_reader :x_min, :x_max, :y_min, :y_max, :z_min, :z_max, :turn, :interval

  def initialize(array)
    @turn = array[0]
    @interval = array[1]
    @x_min, @x_max = array[1][0]
    @y_min, @y_max = array[1][1]
    @z_min, @z_max = array[1][2]
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
    @state_3d = Array.new(grid_size) { Array.new(grid_size) { Array.new(grid_size, 0) } }
    @all_procs = all_procs

    all_procs.each do |proc|
      apply_proc(proc)
    end
  end

  def set_cube(x, y, z, value)
    @state_3d[x + @bound][y + @bound][z + @bound] = value
  end

  def cube(x, y, z)
    @state_3d[x + @bound][y + @bound][z + @bound]
  end

  def count_on
    count = 0
    @state_3d.each do |dim1|
      dim1.each do |dim2|
        dim2.each do |value|
          count += 1 if value == 1
        end
      end
    end
    count
  end

  def apply_proc(proc)
    [*proc.x_min..proc.x_max].each do |x|
      [*proc.y_min..proc.y_max].each do |y|
        [*proc.z_min..proc.z_max].each do |z|
          set_cube(x, y, z, proc.turn)
        end
      end
    end
  end
end

#reactor = Reactor.new(all_procs, 50)
#p reactor.count_on
#raise "e"

class GridSet # Set define as all union of intervals in array_intervals
  attr_reader :array_intervals

  def initialize(array_intervals)
    @array_intervals = array_intervals
    @memoiz = []
  end

  def compute_card
    n = array_intervals.length
    card = 0
    [*0..n - 1].each do |k|
      next if k > 10
      sum = 0
      all_combinations = array_intervals.combination(k + 1).to_a
      p all_combinations.length
      all_combinations.each do |combination|
        sum += inter_intervals_card(combination)
      end
      card += (-1)**k * sum
    end
    card
  end

  def intersection_vector
    vector = []
    @array_intervals.each_with_index do |interval1, i|
      @array_intervals.each_with_index do |interval2, j|
        next if i >= j

        intersection = intersection_3d(interval1, interval2)

        next if intersection.nil?

        vector.push([i, j])
      end

    end
    vector
  end

  def intersection_vector2
    vector = Array.new(@array_intervals.length, [])
    @array_intervals.each_with_index do |interval1, i|
      @array_intervals.each_with_index do |interval2, j|
        next if i >= j

        intersection = intersection_3d(interval1, interval2)

        next if intersection.nil?

        vector[i].push(j)
      end
    end
    vector
  end

  def all_combinaisons2(order)
    return @memoiz[order - 1] unless @memoiz[order - 1].nil?

    if order == 2
      @memoiz[order - 1] = intersection_vector
    elsif order == 1
      @memoiz[order - 1] = [*0..@array_intervals.length - 1].map { |e| [e] }
    else
      accum = []
      previous_combinations_array = all_combinaisons2(order - 1)
      p "order"
      p order
      p previous_combinations_array.length
      #p previous_combinations_array
      previous_combinations_array.each_with_index do |combination, i_previous_combi|
        #p previous_combinations_array.length - i_previous_combi
        [*0..@array_intervals.length - 1].each do |i|
          next if combination.include?(i)

          hyp_set = [*combination, i]
          next if inter_intervals_card(hyp_set.map { |index| @array_intervals[index] }) == 0 #|| inter_intervals_card(hyp_set.map { |index| @array_intervals[index] }) == 0

          # Autre condition
          combinaisons = hyp_set.combination(order - 1).to_a
          #p "fini"

          check = true
          combinaisons.each do |combi|
            if !previous_combinations_array.include?(combi)
              check = false
              break
            end
          end
          accum.push(hyp_set) if check
        end
      end
      #p accum
      @memoiz[order - 1] = accum.uniq
    end
    @memoiz[order - 1]
  end

  def all_combinaisons(order)
    return @memoiz[order - 1] unless @memoiz[order - 1].nil?

    if order == 2
      @memoiz[order - 1] = intersection_vector
    elsif order == 1
      @memoiz[order - 1] = [*0..@array_intervals.length - 1].map { |e| [e] }
    else
      accum = []
      previous_combinations_array = all_combinaisons(order - 1)
      p "order"
      p order
      p previous_combinations_array.length
      previous_combinations_array.each_with_index do |combination, i|
        #p previous_combinations_array.length - i
        [*0..@array_intervals.length - 1].each do |i|
          next if combination.include?(i)

          hyp_set = [*combination, i]
          #p "combi"
          combinaisons = hyp_set.combination(order - 1).to_a
          #p "fini"

          check = true
          combinaisons.each do |combi|
            if !previous_combinations_array.include?(combi)
              check = false
              break
            end
          end
          accum.push(hyp_set) if check
          if !check && inter_intervals_card(hyp_set.map { |index| @array_intervals[index] }) != 0 && inter_intervals_card_strict(hyp_set.map { |index| @array_intervals[index] }) != 0
            p inter_intervals_card(hyp_set.map { |index| @array_intervals[index] })
            p inter_intervals_card_strict(hyp_set.map { |index| @array_intervals[index] })
            tmp = hyp_set.map do |index|
              p @array_intervals[index]
            end
            interval1, interval2, interval3 = tmp
            p intersection_3d(interval1, interval2)
            raise "e"
          end
        end
      end
      @memoiz[order - 1] = accum
    end
    @memoiz[order - 1]
  end

  def compute_card3
    n = array_intervals.length
    card = 0
    [*0..n - 1].each do |k|
      #next if k > 10
      sum = 0
      all_combinations = all_combinaisons2(k + 1).map do |combinaison|
        combinaison.map do |i|
          @array_intervals[i]
        end
      end
      all_combinations.each do |combination|
        sum += inter_intervals_card(combination)
      end
      card += (-1)**k * sum
    end
    card
  end

  def compute_card2(array_intervals)
    sum = 0
    if array_intervals.length == 2
      set1 = @array_intervals[0]
      set2 = @array_intervals[1]
      intersection = intersection_3d(set1, set2)
      interval_card(set1) + interval_card(set2) - interval_card(intersection)
    else
      set1 = array_intervals[0]
      tmp = interval_card(set1)
      array_intervals.each_with_index do |interval, i|
        next if i == 0

        intersection = intersection_3d(set1, interval)
        next if intersection.nil?

         
      end
      
    end
  end

  def non_isolates_intervals
    return [0]
    accum = []
    @array_intervals.each do |interval1|
      tmp = []
      @array_intervals.each do |interval2|
        intersection = intersection_3d(interval1, interval2)
        #p 'tt' if intersection.nil?
        next if intersection.nil?

        tmp.push(intersection)
      end
      next if tmp.empty?

      accum.push(interval1)
    end
  end

  def add(interval)
    @array_intervals.push(interval)
  end

  def remove(interval_to_remove)
    intervals_to_add = []
    intervals_to_delete = []
    @array_intervals.each do |interval|

      # Find intersection
      intersection = intersection_3d(interval, interval_to_remove)

      next if intersection.nil?

      interval1_x, interval1_y, interval1_z = interval
      interval2_x, interval2_y, interval2_z = intersection

      x_array = [*interval1_x, *interval2_x].uniq.sort
      y_array = [*interval1_y, *interval2_y].uniq.sort
      z_array = [*interval1_z, *interval2_z].uniq.sort
      [*0..x_array.length - 2].map do |ix|
        [*0..y_array.length - 2].map do |iy|
          [*0..z_array.length - 2].map do |iz|
            x_min = x_array[ix]
            x_max = x_array[ix + 1]
            y_min = y_array[iy]
            y_max = y_array[iy + 1]
            z_min = z_array[iz]
            z_max = z_array[iz + 1]
            new_interval = [[x_min, x_max], [y_min, y_max], [z_min, z_max]]
            next if new_interval == intersection

            intervals_to_add.push(new_interval)
          end
        end
      end

      # On ajoute l'intersection entre tous les côté d'interval_to_remove et de interval
      interval_x, interval_y, interval_z = interval_to_remove

      interval_x.each do |x|
        border_interval = [[x, x], interval_y, interval_z]
        new_interval =  intersection_3d(interval, border_interval)
        intervals_to_add.push(new_interval)
      end
      interval_y.each do |y|
        border_interval = [interval_x, [y, y], interval_z]
        new_interval =  intersection_3d(interval, border_interval)
        intervals_to_add.push(new_interval)
      end
      interval_z.each do |z|
        border_interval = [interval_x, interval_y, [z, z]]
        new_interval =  intersection_3d(interval, border_interval)
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

  def remove2(interval_to_remove)
    intervals_to_add = []
    intervals_to_delete = []
    @array_intervals.each do |interval|
      p "boucle"
      p interval
      # Find intersection
      intersection = intersection_3d(interval, interval_to_remove)
      p intersection
      next if intersection.nil?

      interval1_x, interval1_y, interval1_z = interval
      interval2_x, interval2_y, interval2_z = intersection

      if intersection == interval
        #next
      end

      interval1_x.each do |x1|
        interval2_x.each do |x2|
          next if x1 == x2

          interval1_y.each do |y1|
            interval2_y.each do |y2|
              next if y1 == y2

              interval1_z.each do |z1|
                interval2_z.each do |z2|
                  next if z1 == z2

                  x_min = [x1, x2].min
                  x_max = [x1, x2].max
                  y_min = [y1, y2].min
                  y_max = [y1, y2].max
                  z_min = [z1, z2].min
                  z_max = [z1, z2].max

                  new_interval = [[x_min, x_max], [y_min, y_max], [z_min, z_max]]
                  p new_interval
                  next if intersection_3d(new_interval, intersection) == intersection #&& intersection != interval
                  
                  #if strict_in_interval_3d?(x_min, y_min, z_min, interval_to_remove) || strict_in_interval_3d?(x_max, #y_max, z_max, interval_to_remove)
                  #  new_interval = [[x_min, x_max], [y_min, y_max], [z_min, z_max]]
                  #  next
                  #end

                  intervals_to_add.push(new_interval)
                end
              end
            end
          end
        end
      end
      intervals_to_delete.push(interval)
      intervals_to_add = simplify(intervals_to_add)
    end
    intervals_to_delete.each do |e|
      @array_intervals.delete(e)
    end

    intervals_to_add = simplify(intervals_to_add)
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

    interval_x[0] == interval_x[1] && interval_y[0] == interval_y[1] && interval_z[0] == interval_z[1]
  end


  def voisins?(interval_point1, interval_point2)
    interval1_x, interval1_y, interval1_z = interval_point1
    interval2_x, interval2_y, interval2_z = interval_point2

    (interval1_x == interval2_x && interval1_y == interval2_y && (interval1_z[0] - interval2_z[0]).abs == 1) || (interval1_x == interval2_x && interval1_z == interval2_z && (interval1_y[0] - interval2_y[0]).abs == 1) || (interval1_y == interval2_y && interval1_z == interval2_z && (interval1_x[0] - interval2_x[0]).abs == 1)
  end

  def union(interval1, interval2)
    return nil if interval1.nil? || interval2.nil? || intersection_3d(interval1, interval2).nil?

    #if intersection_3d(interval1, interval2).nil? && !(is_single_point?(interval1) && is_single_point?(interval2) && voisins?(interval1, interval2))
     # return nil
    #end

    interval1_x, interval1_y, interval1_z = interval1
    interval2_x, interval2_y, interval2_z = interval2

    if interval1_x == interval2_x && interval1_y == interval2_y
      interval_z = [[*interval1_z, *interval2_z].min, [*interval1_z, *interval2_z].max]
      return [interval1_x, interval1_y, interval_z]
    elsif interval1_x == interval2_x && interval1_z == interval2_z
      interval_y = [[*interval1_y, *interval2_y].min, [*interval1_y, *interval2_y].max]
      return [interval1_x, interval_y, interval1_z]
    elsif interval1_y == interval2_y && interval1_z == interval2_z
      interval_x = [[*interval1_x, *interval2_x].min, [*interval1_x, *interval2_x].max]
      return [interval_x, interval1_y, interval1_z]
    elsif is_include_in_other_interval_3d?(interval1, interval2)
      return interval2
    elsif is_include_in_other_interval_3d?(interval2, interval1)
      return interval1
    end
    nil
  end

  def is_include_in_other_interval_1d?(interval, other_interval)
    x_min = interval.min
    x_max = interval.max
    in_interval_1d?(x_min, other_interval) && in_interval_1d?(x_max, other_interval)
  end

  def strict_is_include_in_other_interval_1d?(interval, other_interval)
    x_min = interval.min
    x_max = interval.max
    strict_in_interval_1d?(x_min, other_interval) && strict_in_interval_1d?(x_max, other_interval)
  end

  def is_include_in_other_interval_3d?(interval, other_interval)
    interval1_x, interval1_y, interval1_z = interval
    interval2_x, interval2_y, interval2_z = other_interval
    is_include_in_other_interval_1d?(interval1_x, interval2_x) && is_include_in_other_interval_1d?(interval1_y, interval2_y) && is_include_in_other_interval_1d?(interval1_z, interval2_z)
  end

  def strict_is_include_in_other_interval_3d?(interval, other_interval)
    interval1_x, interval1_y, interval1_z = interval
    interval2_x, interval2_y, interval2_z = other_interval
    strict_is_include_in_other_interval_1d?(interval1_x, interval2_x) && strict_is_include_in_other_interval_1d?(interval1_y, interval2_y) && strict_is_include_in_other_interval_1d?(interval1_z, interval2_z)
  end

  def in_interval_1d?(x, interval)
    x_min = interval.min
    x_max = interval.max
    x <= x_max && x >= x_min
  end

  def strict_in_interval_1d?(x, interval)
    x_min = interval.min
    x_max = interval.max
    x < x_max && x > x_min
  end

  def strict_in_interval_3d?(x, y, z, interval)
    interval_x, interval_y, interval_z = interval
    strict_in_interval_1d?(x, interval_x) && strict_in_interval_1d?(y, interval_y) && strict_in_interval_1d?(z, interval_z)
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

  def intersection_3d(interval1, interval2)
    interval1_x, interval1_y, interval1_z = interval1
    interval2_x, interval2_y, interval2_z = interval2
    intersection_x = intersection_1d(interval1_x, interval2_x)
    intersection_y = intersection_1d(interval1_y, interval2_y)
    intersection_z = intersection_1d(interval1_z, interval2_z)
    if intersection_x.nil? || intersection_y.nil? || intersection_z.nil?
      nil
    else
      [intersection_x, intersection_y, intersection_z]
    end
  end

  def interval_card(interval)
    interval_x, interval_y, interval_z = interval
    (interval_x.max - interval_x.min + 1) * (interval_y.max - interval_y.min + 1) * (interval_z.max - interval_z.min + 1)
  end

  def interval_card_strict(interval)
    interval_x, interval_y, interval_z = interval
    (interval_x.max - interval_x.min) * (interval_y.max - interval_y.min) * (interval_z.max - interval_z.min)
  end

  def inter_intervals_card_strict(array)
    tmp = array[0]
    [*1..array.length - 1].each do |i|
      intersection = intersection_3d(tmp, array[i])
      if intersection.nil?
        #p "nilll"
        return 0
      end

      tmp = intersection
    end
    interval_card_strict(tmp)
  end

  def inter_intervals_card(array)
    tmp = array[0]
    [*1..array.length - 1].each do |i|
      intersection = intersection_3d(tmp, array[i])
      if intersection.nil?
        #p "nilll"
        return 0
      end

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
    interval_x, interval_y, interval_z = all_procs[i].interval
    new_interval = [[interval_x[0] - 1, interval_x[1] + 1], [interval_y[0] - 1, interval_y[1] + 1], [interval_z[0] - 1, interval_z[1] + 1]]
    reactor.remove(new_interval)
  end
  reactor.self_simplify
  p i
end

p reactor.array_intervals.length
#p reactor.non_isolates_intervals.length
#p reactor.all_combinaisons(6).length
p reactor.compute_card3
p "la"
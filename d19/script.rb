
class Scanner
  attr_reader :beacons_distances, :nbr_of_beacons, :scanner_pos, :beacons_array

  def initialize(beacons_array, scanner_pos)
    @beacons_array = beacons_array
    @nbr_of_beacons = beacons_array.length
    @beacons_distances = Array.new(@nbr_of_beacons){Array.new(@nbr_of_beacons)}
    [*0..@nbr_of_beacons - 1].each do |i|
      [*0..@nbr_of_beacons - 1].each do |j|
        @beacons_distances[i][j] = distance(i,j)
      end
    end
    @scanner_pos = scanner_pos
  end

  def position(beacon_index)
    @beacons_array[beacon_index]
  end

  def distance(i,j)
    pos1 = position(i)
    pos2 = position(j)
    x1,y1,z1 = pos1
    x2,y2,z2= pos2
    Math.sqrt((x1 - x2).pow(2) + (y1 - y2).pow(2) + (z1 - z2).pow(2)).round(3)
  end
  
  def intersections(other_scanner, i, j)
    raise "Error" unless other_scanner.is_a? Scanner

    tmp = []
    beacons_distances[i].each_with_index do |d_k, k|
      other_scanner.beacons_distances[j].each_with_index do |d_l, l|
        tmp.push([k,l,d_k]) if d_k == d_l
      end
    end
    tmp
  end

  def set_scanner_position(position)
    @scanner_pos = position
  end

  def absolutes_positions
    raise "error" if @scanner_pos.nil?
    array = []
    @beacons_array.map do |position|
      array << [position[0] + @scanner_pos[0], position[1] + @scanner_pos[1], position[2] + @scanner_pos[2]]
    end
    array
  end

  def manathan_distance(other_scanner)
    pos_self = scanner_pos
    pos_other = other_scanner.scanner_pos
    (pos_self[0] - pos_other[0]).abs + (pos_self[1] - pos_other[1]).abs + (pos_self[2] - pos_other[2]).abs
  end

  def check_solution(scanner_ref, correspondances_array, new_positions_in_self)
    pos_scanner_ref = scanner_ref.scanner_pos

    # Compute solution for this axes permutation with the first correspondance
    pos_beacon_in_ref = scanner_ref.position(correspondances_array[0][0])
    pos_beacon_in_self = new_positions_in_self[correspondances_array[0][1]]
    x = pos_scanner_ref[0] + pos_beacon_in_ref[0] - pos_beacon_in_self[0]
    y = pos_scanner_ref[1] + pos_beacon_in_ref[1] - pos_beacon_in_self[1]
    z = pos_scanner_ref[2] + pos_beacon_in_ref[2] - pos_beacon_in_self[2]
    scanner_pos_hyp = [x, y, z]

    # Test if this solution is correct and return if not the case
    correspondances_array.each_with_index do |correspondance, i|
      next if i == 0
      pos_beacon_in_ref = scanner_ref.position(correspondance[0])
      pos_beacon_in_self = new_positions_in_self[correspondance[1]]
      x = pos_scanner_ref[0] + pos_beacon_in_ref[0] - pos_beacon_in_self[0]
      y = pos_scanner_ref[1] + pos_beacon_in_ref[1] - pos_beacon_in_self[1]
      z = pos_scanner_ref[2] + pos_beacon_in_ref[2] - pos_beacon_in_self[2]
      return nil if x != scanner_pos_hyp[0] || y != scanner_pos_hyp[1] || z != scanner_pos_hyp[2]
    end
    return scanner_pos_hyp
  end

  # Sans changer le array
  def positions_if_permute_axes(permut, neg)
    new_positions = []
    @beacons_array.each_with_index do |beacon, i|
      new_positions.push(beacon.dup)
    end
    [*0..nbr_of_beacons - 1].each do |beacon_index|
      x = new_positions[beacon_index][permut[0]]
      y = new_positions[beacon_index][permut[1]]
      z = new_positions[beacon_index][permut[2]]
      new_positions[beacon_index] = [neg[0]*x, neg[1]*y, neg[2]*z]
    end
    new_positions
  end

  def set_position(scanner_ref, correspondances_array)
    all_permuts = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
    all_negs = [[1, 1, 1], [-1, 1, 1], [-1, -1, 1], [-1, 1, -1], [1, -1, 1], [1, -1, -1], [1, 1, -1],[-1, -1, -1]]
    all_permuts.each do |permut|
      all_negs.each do |neg|
        new_positions = positions_if_permute_axes(permut, neg)
        test_position = check_solution(scanner_ref, correspondances_array, new_positions)
        if !test_position.nil?
          @beacons_array = new_positions
          set_scanner_position(test_position)
          return test_position
        end
      end
    end
  end
end

# Parsing input
file = File.open("input.txt")
array = file.readlines.map { |line| line.gsub("\n","") }.reject { |line| line[0..1] == "--" }.map { |line| line.split(",").map(&:to_i) }.slice_after{ |e| e.empty? }.map(&:compact).map { |e| e.reject!(&:empty?) }
array = array[0..array.length - 2] # remove the "END" line of input

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

scanners = array.map.with_index do |e, i|
  if i == 0
    Scanner.new(e, [0,0,0]) # We know the position of scanner 1
  else
    Scanner.new(e, nil)
  end
end

# Compute scanner pair which have 12 common beacons
all_corresp = []
[*0..array.length - 2].each do |index_scanner_i|
  [*index_scanner_i + 1..array.length - 1].each do |index_scanner_j|
    s1 = scanners[index_scanner_i]
    s2 = scanners[index_scanner_j]
    tmp = []
    [*0..s1.nbr_of_beacons - 1].each do |i|
      [*0..s2.nbr_of_beacons - 1].each do |j|
        intercections = s1.intersections(s2, i, j)
        if intercections.length >= 12
          corresp = intercections.find { |e| e[2] == 0.0 }
          tmp.push(corresp[0..1])
        end
      end
    end
    all_corresp.push([index_scanner_i, index_scanner_j, tmp]) unless tmp.empty?
  end
end

# Compute positions of all scanners
stack = [0]
while stack.length < scanners.length
  stack.each do |index_ref|
    corresp_scanners_to_deduct = all_corresp.select{ |e| e[0] == index_ref || e[1] == index_ref}
    corresp_scanners_to_deduct.each do |corresps|
      if corresps[0] == index_ref
        scanner_ref = scanners[corresps[0]]
        scanner_to_compute = scanners[corresps[1]]
        scanner_to_compute.set_position(scanner_ref, corresps[2])
        stack.push(corresps[1])
        all_corresp.delete_if { |e| e == corresps }
      else
        scanner_ref = scanners[corresps[1]]
        scanner_to_compute = scanners[corresps[0]]
        corresps_reverse = [corresps[1], corresps[0], corresps[2].map(&:reverse)]
        scanner_to_compute.set_position(scanner_ref, corresps_reverse[2])
        stack.push(corresps[0])
        all_corresp.delete_if { |e| e == corresps }
      end
    end
  end
end

# Compute all the beacons in absolute position
accum = []
scanners.each do |s|
  s.absolutes_positions.each do |p|
    accum.push(p)
  end
end

# PART 1 - Solution
p accum.uniq.length

# Compute all the manath distances between each scanners
tmp = []
[*0..scanners.length - 2].each do |i|
  [*i+1..scanners.length - 1].each do |j|
    tmp.push(scanners[i].manathan_distance(scanners[j]))
  end
end

# PART 2 - Solution
p tmp.max

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting
p "Time:"
p elapsed
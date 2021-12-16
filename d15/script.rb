# I implement pseudo code for dijkstra algo found here: https://fr.wikipedia.org/wiki/Algorithme_de_Dijkstra

class Graph
  def initialize(dist_matrix, sdeb, sfin)
    @dist_matrix = dist_matrix
    @m = @dist_matrix.length
    @n = @dist_matrix[0].length
    @sdeb = sdeb
    @sfin = sfin
    @weight_matrix = Array.new(@m) { Array.new(@n, Float::INFINITY) }
    @weight_matrix[@sdeb[0]][@sdeb[1]] = 0
    @path = []
    @previous_nodes = Array.new(@m) { Array.new(@n) }
    @queue = [@sdeb]
  end

  def run_dijkstra
    while true
      min_node = find_min_in_queue
      @queue.delete(min_node)
      update_weights(min_node)
      break if min_node == @sfin 
    end
    min_path = find_min_path
    path_size(min_path)
  end

  private

  # Compute all neighbours of node, where we can go from node
  def neighbours(node)
    pos_i = node[0]
    pos_j = node[1]
    out = []
    [*-1..1].each do |i|
      [*-1..1].each do |j|
        next if i.abs == 1 && j.abs == 1
        x = pos_i + i
        y = pos_j + j
        next if (x == pos_i && y == pos_j) || x < 0 || x > @m - 1 || y < 0 || y > @n - 1 
        out.push([pos_i + i, pos_j + j])
      end
    end
    out
  end

  def weight_node(node)
    @weight_matrix[node[0]][node[1]]
  end

  def update_weights(last_node)
    neighbours = neighbours(last_node)
    neighbours.each do |node|
      tmp = weight_node(last_node) + distance(last_node, node)
      if weight_node(node) > tmp
        @queue |= [node]
        @weight_matrix[node[0]][node[1]] = tmp
        @previous_nodes[node[0]][node[1]] = last_node
      end
    end
  end

  def find_min_in_queue
    index_min = @queue.map do |node|
      weight_node(node)
    end.each_with_index.min[1]
    @queue[index_min]
  end

  def find_min_path
    a = []
    s = @sfin
    while s != @sdeb
      a.push(s)
      s = @previous_nodes[s[0]][s[1]]
    end
    a.push(@sdeb)
    a.reverse
  end

  def distance(node1, node2)
    if neighbours(node1).include?(node2)
      @dist_matrix[node2[0]][node2[1]]
    else
      Float::INFINITY
    end
  end

  def path_size(path)
    distance = 0
    node1 = path[0]
    [*1..(path.length - 1)].each do |i|
      node2 = path[i]
      distance += distance(node1, node2)
      node1 = node2
    end
    distance
  end

end

file = File.open('input.txt')
array = file.readlines.map { |line| line.gsub("\n", '').split("").map(&:to_i) }

## PART 1
sdeb = [0,0]
sfin = [array.length - 1, array[0].length - 1]
graph = Graph.new(array, sdeb, sfin)
p graph.run_dijkstra

## PART 2
m = array.length
n = array[0].length
array2 = Array.new(5 * m) { Array.new(5 * n) } # array2 will be the complete map
tmp = 0
[*0..4].map do |k1|
  tmp += k1
  [*0..4].map do |k2|
    tmp += k2
    array.each_with_index do |line, i|
      line.each_with_index do |e, j|
        array2[k1 * m + i][k2 * n +j] = (e + k2 + k1 - 1) % 9 + 1
      end
    end
  end
end
sfin = [5 * m - 1, 5 * n - 1]
graph = Graph.new(array2, sdeb, sfin)
starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
p graph.run_dijkstra # solution
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting
p elapsed # elapsed time in s

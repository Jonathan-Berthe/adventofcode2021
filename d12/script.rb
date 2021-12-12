class Graph
  def initialize(input)
    @nodes = nodes(input)
    @matrix = adjacency_matrix(input) # Matrice d'adjacence
    @all_paths = []
  end

  # All nodes of the graph
  def nodes(input)
    nodes = ["start", "end"]
    input.each do |line|
      line.each do |e|
        nodes.insert(1, e) unless nodes.include?(e)
      end
    end
    nodes
  end

  # Compute the adjency matrix
  def adjacency_matrix(input)
    nodes_size = @nodes.length
    matrix = Array.new(nodes_size) { Array.new(nodes_size, 0) }
    input.each do |line|
      node_i = @nodes.find_index(line[0])
      node_j = @nodes.find_index(line[1])
      matrix[node_i][node_j] = 1
      matrix[node_j][node_i] = 1
    end
    matrix
  end

  def big_cave?(pos)
    !/[[:upper:]]/.match(@nodes[pos]).nil?
  end

  def end?(pos)
    pos == @nodes.length - 1
  end

  def start?(pos)
    pos == 0
  end

  # return all adjacents nodes of the node which is at the pos position
  def adjacent_nodes(pos)
    @matrix[pos].each_index.select { |i| @matrix[pos][i] == 1 }
  end

  # Giving a path (array of nodes's position), compute recursively all the paths beginning by "path" until having a closing path (wich is finished by "end") and append it to @all_path - Part 1
  def compute_next_paths_part1(path)
    pos_last = path.last
    if end?(pos_last)
      @all_paths.push(path)
      return
    end

    adjacent_nodes(pos_last).each do |pos|
      # Wrong way, we can't continue the path with this pos
      next if !big_cave?(pos) && path.include?(pos)

      new_path = [*path, pos]
      compute_next_paths_part1(new_path)
    end
  end

  # Compute all existing path - Part 1
  def all_paths_part1
    @all_paths = []
    compute_next_paths_part1([0]) # [0] = [start] => initial path
    @all_paths.map do |path|
      path.map do |e|
        @nodes[e]
      end
    end
  end

  # Check if we already visit twice a small cave in the path
  def already_has_twice_small_cave(path)
    test = false
    path.each do |pos|
      next if big_cave?(pos)

      if path.count(pos) == 2
        test = true
        break
      end
    end
    test
  end

  # Giving a path (array of nodes's position), compute recursively all the paths beginning by "path" until having a closing path (wich is finished by "end") and append it to @all_path - Part 2
  def compute_next_paths_part2(path)
    pos_last = path.last
    if end?(pos_last)
      @all_paths.push(path)
      return
    end

    adjacent_nodes(pos_last).each do |pos|
      # Wrong way, we can't continue the path with this pos
      next if start?(pos) || (!big_cave?(pos) && path.include?(pos) && already_has_twice_small_cave(path))

      new_path = [*path, pos]
      compute_next_paths_part2(new_path)
    end
  end

  # Compute all existing path - Part 2
  def all_paths_part2
    @all_paths = []
    compute_next_paths_part2([0]) # [0] = [start] => initial path
    @all_paths.map do |path|
      path.map do |e|
        @nodes[e]
      end
    end
  end
end

file = File.open('input.txt')
array = file.readlines.map { |line| line.gsub("\n", '') }.map { |line| line.split('-') }
graph = Graph.new(array)

## Part 1
# p graph.all_paths_part1 # To see all the paths
p graph.all_paths_part1.length

## Part 2
# p graph.all_paths_part2 # To see all the paths
p graph.all_paths_part2.length

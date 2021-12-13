class Paper
  def initialize(input, folds)
    @matrix = initialize_matrix(input)
    @folds = folds
  end

  def initialize_matrix(input)
    x_size = input.map { |line| line[0] }.max + 1
    y_size = input.map { |line| line[1] }.max + 1
    matrix = Array.new(y_size) { Array.new(x_size, 0) }
    input.each do |line|
      x = line[0]
      y = line[1]
      matrix[y][x] = 1
    end
    matrix
  end

  def fold_y(number)
    y_size = @matrix.length
    x_size = @matrix[0].length
    number_of_lines_folded = y_size - number - 1
    new_matrix_y_size = [number_of_lines_folded, number].max
    new_matrix = Array.new(new_matrix_y_size) { Array.new(x_size, nil) }
    [*1..number_of_lines_folded].each do |i|
        line1 = number - i < 0 ? Array.new(x_size, 0) : @matrix[number - i]
        line2 = @matrix[number + i]
        new_matrix[new_matrix_y_size - i] = line1.map.with_index do |e, pos|
          [e + line2[pos], 1].min
        end
    end
    new_matrix
  end

  def fold_x(number)
    y_size = @matrix.length
    x_size = @matrix[0].length
    number_of_lines_folded = x_size - number - 1
    new_matrix_x_size = [number_of_lines_folded, number].max
    new_matrix = Array.new(y_size) { Array.new(new_matrix_x_size, nil) }
    [*1..number_of_lines_folded].each do |i|
        column1 = number - i < 0 ? Array.new(y_size, 0) : @matrix.map { |line| line[number - i] }
        column2 = @matrix.map { |line| line[number + i] }
        column1.each_with_index do |e, pos|
          new_matrix[pos][new_matrix_x_size - i] = [e + column2[pos], 1].min
        end
    end
    new_matrix
  end

  def visible_dots_size
    @matrix.map do |line|
      line.count(1)
    end.sum
  end

  def run1
    @matrix = fold_x(@folds[0][1].to_i) if @folds[0][0] == "x"
    @matrix = fold_y(@folds[0][1].to_i) if @folds[0][0] == "y"
    visible_dots_size
  end

  def run2
    @folds.each do |line|
      @matrix = fold_x(line[1].to_i) if line[0] == "x"
      @matrix = fold_y(line[1].to_i) if line[0] == "y"
    end
    @matrix
  end

end

file = File.open("dummy.txt")
all_input = file.readlines.map { |line| line.gsub("\n", '') }
input = all_input[0..all_input.find_index("") - 1].map { |line| line.split(",").map(&:to_i) }
folds = all_input[all_input.find_index("") + 1..all_input.length - 1].map { |line| line.gsub("fold along ", "").split("=") }

paper = Paper.new(input, folds)

# PART 1
# p paper.run1

# PART 2 (and read the 8 letters in the output :) ) => LRGPRECB
p paper.run2
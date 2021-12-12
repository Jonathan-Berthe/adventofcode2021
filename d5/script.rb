file = File.open("input.txt")
array = file.readlines.map do |line| 
  new_line = line.split(" -> ")
  new_line.map { |point| point.split(",").map(&:to_i) }
end

# check if a point is in horizontal or vertical segment
def point_is_in_line_rect?(point, line)
  x = point[0]
  y = point[1]
  x_1 = [line[0][0], line[1][0]].min
  y_1 = [line[0][1], line[1][1]].min
  x_2 = [line[0][0], line[1][0]].max
  y_2 = [line[0][1], line[1][1]].max
  (x == x_1 && x == x_2 && y >= y_1 && y <= y_2) || (y == y_1 && y == y_2 && x >= x_1 && x <= x_2)
end

# check if a point is in a segment
def point_is_in_line?(point, line)
  x = point[0]
  y = point[1]
  x_0 = line[0][0]
  y_0 = line[0][1]
  x_f = line[1][0]
  y_f = line[1][1]
  x_1 = [x_0, x_f].min
  y_1 = [y_0, y_f].min
  x_2 = [x_0, x_f].max
  y_2 = [y_0, y_f].max
  return true if (x == x_0 && y == y_0) || (x == x_f && y == y_f)

  return point_is_in_line_rect?(point, line) if (x_0 == x_f) || (y_0 == y_f)

  (x - x_0 == ((x_f - x_0) * (y - y_0)) / (y_f - y_0)) && x.between?(x_1, x_2) && y.between?(y_1, y_2)
end

# return array with all points [x, y] of a line
def points_of_line(line)
  x_0 = line[0][0]
  y_0 = line[0][1]
  x_f = line[1][0]
  y_f = line[1][1]
  result = []
  if x_0 == x_f
    y_1 = [y_0, y_f].min
    y_2 = [y_0, y_f].max
    [*y_1..y_2].each do |y|
      result.push([x_0, y])
    end
  elsif y_0 == y_f
    x_1 = [x_0, x_f].min
    x_2 = [x_0, x_f].max
    [*x_1..x_2].each do |x|
      result.push([x, y_0])
    end
  elsif y_f > y_0 && x_f > x_0
    [*y_0..y_f].each_with_index do |y, c|
      result.push([x_0 + c, y])
    end
  elsif y_f > y_0 && x_f < x_0
    [*y_0..y_f].each_with_index do |y, c|
      result.push([x_0 - c, y])
    end
  elsif y_f < y_0 && x_f < x_0
    [*y_f..y_0].each_with_index do |_, c|
      result.push([x_0 - c, y_0 - c])
    end
  elsif y_f < y_0 && x_f > x_0
    [*y_f..y_0].each_with_index do |_, c|
      result.push([x_0 + c, y_0 - c])
    end
  end
  result
end

# return all overlaped points of 2 lines
def overlaped_points(line1, line2)
  result = []
  points_of_line(line1).each do |point|
    result.push(point) if point_is_in_line?(point, line2)
  end
  result
end

# run
def test(array)
  result = []
  array[0..array.length - 2].each_with_index do |line_i, i|
    array[i + 1..array.length - 1].each do |line_j|
      overlaped_points(line_i, line_j).each { |point| result.push(point) }
    end
  end
  result.uniq
end

result = test(array)
puts result.length

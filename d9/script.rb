file = File.open("input.txt")
array = file.readlines.map { |e| e.strip().split("").map(&:to_i) }

# Calculate size of bassin of a point (i, j) in array
def bassin_size(array, i, j)
  n = array.length
  m = array[0].length 
  count = 1
  value = array[i][j]

  new_array = array

  value_left = j > 0 ? new_array[i][j - 1] : -1
  if j > 0 && value_left > value && value_left != 9
    tmp = bassin_size(new_array, i, j - 1)
    count += tmp[0]
    new_array = tmp[1]
  end

  value_right = j < m - 1 ? new_array[i][j + 1] : -1
  if j < m - 1 && value_right > value && value_right != 9
    tmp = bassin_size(new_array, i, j + 1)
    count += tmp[0]
    new_array = tmp[1]
  end

  value_down = i < n - 1 ? new_array[i + 1][j] : -1
  if i < n - 1 && value_down > value && value_down != 9
    tmp = bassin_size(new_array, i + 1, j)
    count += tmp[0]
    new_array = tmp[1]
  end

  value_up = i > 0 ? new_array[i-1][j] : -1
  if i > 0 && value_up > value && value_up != 9
    tmp = bassin_size(new_array, i - 1, j)
    count += tmp[0]
    new_array = tmp[1]
  end

  new_array[i][j] = - 1
  [count, new_array]
end

def three_max_of_array(array)
  array.sort.last(3)
end

def product_of_elements(array)
  out = 1
  array.each { |e| out *= e }
  out
end

def run(array)
  n = array.length
  m = array[0].length
  out = []
  bassin_sizes = []
  [*0..n - 1].each do |i|
    [*0..m - 1].each do |j|
      value = array[i][j]
      value_left = j > 0 ? array[i][j - 1] : value + 1
      value_right = j < m - 1 ? array[i][j +1 ] : value + 1
      value_up = i > 0 ? array[i - 1][j] : value + 1
      value_down = i < n - 1 ? array[i + 1][j] : value + 1
      if value < value_left && value < value_right && value < value_down && value < value_up
        out.push(value + 1)
        bassin_sizes.push(bassin_size(array, i, j)[0])
      end
    end
  end
  p out.sum # Solution of part 1
  product_of_elements(three_max_of_array(bassin_sizes))
end

p run(array) # Solution of part 2

file = File.open("input.txt")
array = file.readlines.map(&:to_s).map(&:strip)
m = array.length
n = array[0].length
gamma = ''
eps = ''

[*0..n - 1].map do |j|
  count0 = 0
  count1 = 0
  [*0..m - 1].map do |i|
    if array[i][j].to_i == 1
      count1 += 1
    else
      count0 += 1
    end
  end
  if count1 > count0
    gamma += '1'
    eps += '0'
  else
    gamma += '0'
    eps += '1'
  end
end

# Solution Part 1
puts gamma.to_i(2) * eps.to_i(2)

sub_array = array
[*0..n - 1].map do |j|
  count0 = 0
  count1 = 0
  [*0..sub_array.length - 1].map do |i|
    if sub_array[i][j].to_i == 1
      count1 += 1
    else
      count0 += 1
    end
  end
  if count1 >= count0
    sub_array = sub_array.select do |a|
      a[j].to_i == 1
    end
  else
    sub_array = sub_array.select do |a|
      a[j].to_i.zero?
    end
  end
  break if sub_array.length == 1
end

sub_array2 = array
[*0..n - 1].map do |j|
  count0 = 0
  count1 = 0
  [*0..sub_array2.length-1].map do |i|
    if sub_array2[i][j].to_i == 1
      count1 += 1
    else
      count0 += 1
    end
  end
  if count1 >= count0
    sub_array2 = sub_array2.select do |a|
      a[j].to_i.zero?
    end
  else
    sub_array2 = sub_array2.select do |a|
      a[j].to_i == 1
    end
  end
  break if sub_array2.length == 1
end

# Solution Part 2
puts sub_array[0].to_i(2) * sub_array2[0].to_i(2)

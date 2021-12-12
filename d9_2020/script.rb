file = File.open("dummy.txt")
array = file.readlines.map(&:to_i)
param = 5
response = nil
array.each_with_index do |a, i|
  next if i < param
  preamble = array[i-param..i-1]
  preamble_size = preamble.size
  check = 0
  preamble.each_with_index do |p, j|
    break if j == preamble_size - 1
    sub_preamble = preamble[j+1..preamble_size-1]
    sub_preamble.each_with_index do |s, k|
      check = 1 if a == p + s
      break if check == 1
    end
    break if check == 1
  end
  if check == 0
    response = a
    break
  end
end
puts response
array.delete(response)

check = 0
sub = nil
array.each_with_index do |a, i|
  length_sub = 2
  sub = array[i..i+1]
  while length_sub < array.length - i
    if sub.sum == response
      check = 1
      break
    end
    length_sub += 1
    sub = array[i..i+length_sub-1]
  end
  break if check == 1
end
puts sub.sum
puts sub.min + sub.max
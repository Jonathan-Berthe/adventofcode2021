file = File.open("d1.txt")
array = file.readlines.map(&:to_i)
length = array.length

previous = array[0]
count = 0
count2 = 0

array.each_with_index do |a, index|
  count += 1 if a > previous && index.positive?
  previous = a
  next if index > length - 4

  count2 += 1 if array[index + 3] > array[index]
end

puts count
puts count2

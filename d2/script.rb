# Part 1

file = File.open("input.txt")
x = 0
y = 0
file.readlines.each do |l|
  data = l.split
  case data[0]
  when 'up'
    y -= data[1].to_i
  when 'down'
    y += data[1].to_i
  when 'forward'
    x += data[1].to_i
  else
    puts 'ERROR'
  end
end
puts x * y

# Part 2

file = File.open("input.txt")
x = 0
y = 0
z = 0
file.readlines.each do |l|
  data = l.split
  case data[0]
  when 'up'
    z -= data[1].to_i
  when 'down'
    z += data[1].to_i
  when 'forward'
    x += data[1].to_i
    y += data[1].to_i * z
  else
    puts 'ERROR'
  end
end
puts x * y

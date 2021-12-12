input = File.open('input.txt').readline.split(',').map(&:to_i)

# Compute fuel for input and to a position posx - part 1
def fuel(input, posx)
  input.map do |e|
    (e - posx).abs
  end.sum
end

# Compute fuel for input and to a position posx - part 2
def fuel2(input, posx)
  input.map do |e|
    diff = (e - posx).abs
    (diff * (diff + 1) / 2).abs
  end.sum
end

# Calcul of fuel for each position and puts the min one
min = input.min
max = input.max
a = []
[*min..max].map do |e|
  # a.push(fuel(input, e)) # Part 1
  a.push(fuel2(input, e)) # Part 2
end
p a.min

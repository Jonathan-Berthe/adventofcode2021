# Part 1 => brute force...
class Fish
  def initialize(x)
    @x0 = x
  end

  def descendants_direct(days)
    alpha = days > @x0 ? ((days-@x0-1)/7).floor + 1 : 0
    out = [*0..alpha-1].map do |e|
      @x0 + 9 + e*7
    end
    out
  end

  def descendants(days)
    desc_direct = descendants_direct(days)
    count = desc_direct.length
    desc_direct.each do |d_x0|
      child = Fish.new(d_x0)
      count += child.descendants(days)
    end
    count
  end
end

def run_1
  puts "go"
  input = File.open("input.txt").readline.split(",").map(&:to_i)
  days = 80
  count = input.length
  input.each do |x0|
    fish = Fish.new(x0)
    count += fish.descendants(days)
  end
  puts count
end

run_1

# Part 2 - Bit more clever solution ^^
class Simulation
  attr_accessor :fishes

  def initialize(input)
    @fishes = [*0..8].map do |e|
      input.count { |f| f == e }
    end
  end

  def simulate(days)
    days.times do
      zeros = fishes.shift
      fishes[8] = zeros
      fishes[6] += zeros
    end
    fishes.sum
  end
end

def run_2
  puts "go"
  input = File.open("input.txt").readline.split(",").map(&:to_i)
  sim = Simulation.new(input)
  p sim.simulate(256)
end

run_2
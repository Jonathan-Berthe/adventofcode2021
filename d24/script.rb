class String
  def is_integer?
    self.to_i.to_s == self
  end
end

# Parsing

file = File.open("input.txt")
array = file.readlines.map do |line|
  line.gsub("\n",'').split(" ")
end

class IntegerAlu
  attr_accessor :value
  def initialize(value)
    @value = value
  end
end

class AluProgramm
  attr_reader :x, :y, :z, :current_input

  def initialize(instructions)
    @instructions = instructions
    @x = IntegerAlu.new(0)
    @y = IntegerAlu.new(0)
    @z = IntegerAlu.new(0)
    @current_input = IntegerAlu.new(nil)
  end

  def process2(w_array)
    tmp = [[1, 10, 25, 13], [1, 13, 25, 10], [1, 13, 25, 3], [26, -11, 25, 1], [1, 11, 25, 9], [26, -4, 25, 3], [1, 12, 25, 5], [1, 12, 25, 1], [1, 15, 25, 0], [26, -2, 25, 13], [26, -5, 1, 7], [26, -11, 25, 15], [26, -13, 25, 12], [26, -10, 25, 8]]
    z = 0
    [*0..-1].each do |i|
      break
      w = w_array[i].to_i
      x1, x2, x3, x4 = tmp[i]
      if w == (z % 26) + x2
        z = (z / x1)
      else
        z = (z / x1)*(x3 + 1) + (w + x4)
      end
    end
    #return z
    w_accum = []
    [*0..13].each do |i|
      #break
      #p "la"
      w = w_array[i].to_i
      x1, x2, x3, x4 = tmp[i]
      if x1 == 26
        w = (z % 26) + x2
        return -1 if w < 1 || w > 9
        z = (z / 26)
        #p z
      else
        z = (z / x1)*(x3 + 1) + (w + x4)
      end
      w_accum.push(w)
    end
    p w_accum
    z
  end

  def process(all_input_values)
    inputs_to_process = all_input_values
    @instructions.each do |instruction|
      #p "@@@@@@@@@@@@@"
      #p @x.value
      #p @y.value
      #p @z.value
      #p @current_input.value
      #p "@@@@@@@@@@@@@"
      operation = instruction[0]
      case operation
      when "inp"
        @current_input.value = inputs_to_process[0].to_i
        inputs_to_process.shift
      when "add"
        add(instruction[1], instruction[2])
      when "mul"
        mul(instruction[1], instruction[2])
      when "div"
        div(instruction[1], instruction[2])
      when "mod"
        mod(instruction[1], instruction[2])
      when "eql"
        eql(instruction[1], instruction[2])
      else
        raise "invalid instruction"
      end
    end
  end

  def add(a, b)
    term1 = variable_by_id(a)
    term2 = b.is_integer? ? b.to_i : variable_by_id(b).value
    term1.value = term1.value + term2
    #p term2
  end

  def mul(a, b)
    fact1 = variable_by_id(a)
    fact2 = b.is_integer? ? b.to_i : variable_by_id(b).value
    fact1.value = fact1.value * fact2
    #p fact2
  end

  def div(a, b)
    fact1 = variable_by_id(a)
    fact2 = b.is_integer? ? b.to_i : variable_by_id(b).value
    fact1.value = fact1.value / fact2
  end

  def mod(a, b)
    fact1 = variable_by_id(a)
    fact2 = b.is_integer? ? b.to_i : variable_by_id(b).value
    fact1.value = fact1.value % fact2
  end

  def eql(a, b)
    fact1 = variable_by_id(a)
    fact2 = b.is_integer? ? b.to_i : variable_by_id(b).value
    fact1.value = fact1.value == fact2 ? 1 : 0
  end

  def reset
    @x.value = 0
    @y.value = 0
    @z.value = 0
    @current_input.value = nil
  end

  def variable_by_id(id)
    case id
    when "x"
      @x
    when "y"
      @y
    when "z"
      @z
    when "w"
      @current_input
    else
      raise "unknown variable"
    end
  end
end

program = AluProgramm.new(array)

tmp = []
[*1..14].each do |i|
  w = Array.new(14, "0")
  w[i - 1] = "1"
  z = program.process2(w)
  tmp.push(z) #tmp.push(program.z.value)
  program.reset
end

p tmp
coeff = [341857524, 319008724, 318094772, 318129924, 318094772, 318096124, 318094824, 12234412, 318094772, 318094772, 318094772, 318094772, 318094772, 318094773]
#coeff = [4444147742, 4147113342, 4135231966, 4135688942, 4135231966, 4135249542, 4135232642, 4135231992, 4135231966, 4135231966, 4135231966, 4135231966, 4135231966, 4135231967]

w = Array.new(14, "0")
w[0] = "1"
w[1] = "1"
z = program.process2(w)
b = coeff[0] + coeff[1] - z
# b = coeff[0] + coeff[1] - program.z.value
program.reset

[*1..14].each do |i|
  coeff[i - 1] = coeff[i - 1] - b
end

p coeff

nums = "14899271998898".split("")
sum = 0
[*1..14].each do |i|
  sum += coeff[i-1] * nums[i-1].to_i
end
p b
p sum + b
p program.process2(nums)
#p program.z.value
#quit
#tmp = []
#tmp2 = []
#[9999999, 9999997, 9999979, 9997997, 9997979, 9997977, 9997599, 9997597, 9997579, 9997537, 9991999, 9991997, 9499999, 9499997, 9499979, 9497997, 9497979, 9497978, 9497977, 9497579, 9497537, 9491999, 9491997]


[1].each_with_index do |tmp4, i|
  #a = const.to_s
  init = 1111111
  p i
  while init <= 9999999
    #count += 1
    #p i
    p init
    tmp3 = tmp4.to_s.split("")
    nbr = init.to_s.split("")
    if nbr.include?("0")
      init = init + 1
      next
    end
    numbers = [nbr[0], nbr[1], nbr[2], "9", nbr[3], "9", nbr[4], nbr[5], nbr[6], "9", "9", "9", "9", "9"]
    #numbers = [nbr[0], nbr[1], tmp3[0], nbr[2], tmp3[1], nbr[3], nbr[4], nbr[5], tmp3[2], tmp3[3], tmp3[4], tmp[5], tmp3[6], nbr[6]]
    #p numbers
    #numbers = [1, 1, nbr[0], 1, nbr[1], 1, 1, 1, nbr[2], nbr[3], nbr[4], nbr[5], nbr[6], 1]
    z = program.process2(numbers)
    #p z
   # p "----"
    #unless tmp.include?(z)
      #tmp.push(z) 
      #tmp2.push(init)
    #end
    #p z
    #p numbers
    #sum = b
    #[*1..14].each do |i|
    #  sum += coeff[i-1] * numbers[i-1].to_i
    #end
    #p sum
    #program.process(numbers)
    #p program.z.value
    #p sum
    if z == 0#1sum == 0
      p numbers
      p "end"
      break
    end
    init = init + 1
  end
end
#p tmp
#p tmp2



raise "e"
#array = array[234..array.length - 1]
#program = AluProgramm.new(array)

[*1..9].each do |wd|
  [*9 + wd..17 + wd].each do |zd|
    x1 = 26
    x2 = -10
    x3 = 25
    x4 = 8
    #zd = 1009 + wd
    check = (zd % 26) + x2 == wd
    if check
      zf = zd / x1 
    else
      zf = (zd / x1) + wd + x4
    end
    
    tmp = [["add", "z", zd.to_s], *array]
    program = AluProgramm.new(tmp)
    program.process([wd])
    if zf == 0
      p "-------"
      p check
      p zf
      p zd
      p wd
      p program.z.value
    end
  end 
  #program.reset
end
#p array





tmp = [[1, 10, 25, 13], [1, 13, 25, 10], [1, 13, 25, 3], [26, -11, 25, 1], [1, 11, 25, 9], [26, -4, 25, 3], [1, 12, 25, 5], [1, 12, 25, 1], [1, 15, 25, 0], [26, -2, 25, 13], [26, -5, 1, 7], [26, -11, 25, 15], [26, -13, 25, 12], [26, -10, 25, 8]]

def recursion(array, stack_z, stack_w)
  x1, x2, x3, x4 = array[0]
  zd = stack_z.last
  #raise "case" if stack_w.length < 3
  if x1 == 1
    [*1..9].reverse.each do |w|
      zf = zd*(x3 + 1) + w + x4
      p zf
      if zf == 0 #&& stack_z.length == 13
        p stack_w
        raise "fini"
      end
      recursion(array[1..array.length - 1], [*stack_z, zf], [*stack_w, w])
    end
  elsif x1 == 26
    w = zd + x2
    return nil if w < 1 || w > 9

    recursion(array[1..array.length - 1], [*stack_z, zf], [*stack_w, w])
  else
    raise "not possible..."
  end
end

#recursion(tmp, [0], [])

p tmp.length


#raise "e"
nums = "94691271141118".split("")
program.process(nums)

p program.z.value
p program.y.value
p program.x.value
p program.current_input.value


[*1..14].each do |i|
  w = Array.new(14, 0)
  array[i - 1] = 1
  program.process(array)
end

raise "e"
init = 99999999999999
count = 0
while init > 0
  count += 1
  #p "-------"
  #p init
  numbers = init.to_s.split("")
  #program.process(numbers)
  #p program.z.value
  #if program.z == 0
    #break
  #end
  init = init - 1
  if count > 1000000000
    p count
    count = 0
  end
  #break if count > 10
end

p init


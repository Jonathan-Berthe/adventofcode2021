class Polymer
  def initialize(template, input)
    # initial polymer. ex: "PHOSBSKBBBFSPPPCCCHN"
    @polymer_template = template

    # ex: [["KO", "H"], ["OK", "P"],..,["FN", "O"]]
    @input = input 

    # ex: @new_generated_pairs[1] = [27, 30] => pair @input[1] generate pairs @input[27] and @input[30] after a step
    @new_generated_pairs = new_generated_pairs 

    # all existing letters of the polymer, ex: ["K", "O", "B", "S", "H", "P", "C", "N", "V", "F"]
    @all_letters = all_letters

    # @pairs_counter[i] = n => we have n pairs @input[i] in polymer
    @pairs_counter = Array.new(@input.length, 0)
    count_pairs_in_polymer.each do |e|
      @pairs_counter[index_of_pair(e[1])] = e[0]
    end

    # @letters_counter[i] = n => we have n letters @all_letters[i] in polymer
    @letters_counter = Array.new(@all_letters.length, 0)
    @all_letters.each_with_index do |e, i|
      @letters_counter[i] = @polymer_template.count(e)
    end
  end

  def run(steps)
    steps.times do 
      do_step
    end
    max = @letters_counter.max
    min = @letters_counter.min
    max - min
  end

  
  private

  # Compute all existing letters of the polymer (ex: ["K", "O", "B", "S", "H", "P", "C", "N", "V", "F"])
  def all_letters
    out = []
    @input.each do |e|
      pair = e[0]
      out.push(pair[0])
      out.push(pair[1])
    end
    out.uniq
  end

  # Return all indice of target in str
  def indices_of_matches(str, target)
    sz = target.size
    (0..str.size-sz).select { |i| str[i,sz] == target }
  end

  # Compute @new_generated_pairs. ex: @new_generated_pairs[1] = [27, 30] => pair @input[1] generate pairs @input[27] and @input[30] after a step
  def new_generated_pairs
    out = Array.new(@input.length, 0)
    @input.each_with_index do |e, i|
      generator_pair = e[0]
      inserted_char = e[1]
      generated_pair1 = generator_pair[0] + inserted_char
      generated_pair2 = inserted_char + generator_pair[1]
      out[i] = [index_of_pair(generated_pair1), index_of_pair(generated_pair2)].compact
    end
    out
  end

  def index_of_pair(pair)
    @input.index { |e| e[0] == pair}
  end

  # Compute array with array[i] = [5, "BO"] => We have 5 times "BO" pairs in @polymer_template.
  def count_pairs_in_polymer
    out = []
    @input.each_with_index do |rule|
      indices = indices_of_matches(@polymer_template, rule[0])
      out.push([indices.length, rule[0]])
    end
    out
  end

  # One step
  def do_step
    tmp = @pairs_counter.dup
    @pairs_counter.each_with_index do |pair_counter, i|
      @new_generated_pairs[i].each do |e|
        tmp[e] += pair_counter
      end
      letter_generated = @input[i][1]
      @all_letters.each_with_index do |letter, letter_index|
        @letters_counter[letter_index] += pair_counter if letter == letter_generated
      end
      tmp[i] -= pair_counter
    end
    @pairs_counter = tmp
  end

end


file = File.open("input.txt")
all_input = file.readlines.map { |line| line.gsub("\n", '') }
template = all_input[0]
input = all_input[2..all_input.length - 1].map { |line| line.split(" -> ") }

polymer = Polymer.new(template, input)
# p polymer.run(10) # Part 1
p polymer.run(40) # Part 2
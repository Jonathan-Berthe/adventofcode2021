require 'json'

class Pair
  attr_accessor :content, :deep, :is_left, :parent, :children, :is_right

  def initialize(content, parent, is_left, deep)
    @parent = parent
    @is_left = is_left
    @children = []
    @deep = deep
    @content = nil
    if content.is_a? Integer
      @content = content
      return
    end
    content.each_with_index do |e, i|
      if e.is_a? Integer
        child_is_left = i == 0 ? true : false
        new_pair = Pair.new(e, self, child_is_left, @deep + 1)
        @children.push(new_pair)
      else
        child_is_left = i == 0 ? true : false
        new_pair = Pair.new(e, self, child_is_left, @deep + 1)
        @children.push(new_pair)
      end
    end
  end

  def regular_value?
    children.length == 0
  end

  def is_pair_of_numbers
    check = true
    return false if regular_value?
    @children.each do |e|
      if !e.regular_value?
        check = false
        break
      end
    end
    check
  end

  def is_right
    is_left.nil? ? nil : !is_left
  end

  def change_child(i, value)
    @children[i] = value
  end

  def compute_magnitude
    if regular_value?
      content
    else
      3 * children[0].compute_magnitude + 2 * children[1].compute_magnitude
    end
  end

  def compute_array # Return the corresponding array of the Pair tree
    array = []
    children.each_with_index do |e, i|
      if e.regular_value?
        array[i] = e.content
      else
        array[i] = e.compute_array
      end
    end
    array
  end

  def first_right_number_in_tree_parent
    return if !is_pair_of_numbers

    # Up to parent
    searching_pair = self
    check_is_right = is_right
    while check_is_right
      parent = searching_pair.parent
      searching_pair = parent
      check_is_right = searching_pair.is_right
    end

    return if searching_pair.parent.nil?

    searching_pair = searching_pair.parent

    # Down to first right number and return the parent pair
    parent = searching_pair.children[1]
    
    return parent if parent.regular_value?
    
    child_to_check = parent.children[0]
    while !child_to_check.regular_value?
      child_to_check = child_to_check.children[0]
      break if child_to_check.regular_value?
    end

    child_to_check
  end

  def first_left_number_in_tree_parent
    return if !is_pair_of_numbers

    # Up to parent
    searching_pair = self
    check_is_left = @is_left
    while check_is_left
      parent = searching_pair.parent
      searching_pair = parent
      check_is_left = searching_pair.is_left
    end

    return if searching_pair.parent.nil?

    searching_pair = searching_pair.parent
    # Down to first right number and return the parent pair
    parent = searching_pair.children[0]
    return parent if parent.regular_value?
    
    child_to_check = parent.children[1]
    while !child_to_check.regular_value?
      child_to_check = child_to_check.children[1]
      break if child_to_check.regular_value?
    end

    child_to_check
  end

  def explode
    raise "Not a pair of numbers" if !is_pair_of_numbers
    raise "Can't explose, deep < 4" if deep < 4

    left_value = children[0].content
    right_value = children[1].content
    first_left_number_in_tree_parent.content += left_value unless first_left_number_in_tree_parent.nil?
    first_right_number_in_tree_parent.content += right_value unless first_right_number_in_tree_parent.nil?

    @children = []
    @content = 0
  end

  def split
    raise "Not a regular value" if !regular_value?
    raise "Not over 10" if content < 10

    left = Pair.new((content.to_f / 2).floor, self, true, deep + 1)
    right = Pair.new((content.to_f / 2).ceil, self, false, deep + 1)
    @children = [left, right]
    @content = nil
  end

  def find_children_to_explode
    children_to_explode = []
    children.each do |e|
      if e.deep >= 4 && e.is_pair_of_numbers
        children_to_explode.push(e) 
      else
        children_to_explode.push(*e.find_children_to_explode)
      end
    end
    children_to_explode
  end
  
  def find_children_to_split
    children_to_split = []
    children.each do |e|
      if e.regular_value? && e.content >= 10
        children_to_split.push(e) 
      else
        children_to_split.push(*e.find_children_to_split)
      end
    end
    children_to_split
  end

  def reduce
    while true
      stack_to_explode = find_children_to_explode
      if !stack_to_explode.empty?
        elem_to_explode = stack_to_explode[0]
        elem_to_explode.explode
        next
      end
      stack_to_split = find_children_to_split
      if !stack_to_split.empty?
        elem_to_split = stack_to_split[0]
        elem_to_split.split
        next
      end
      break
    end
  end

  def add(pair)
    array1 = self.compute_array
    array2 = pair.compute_array
    new_pair = Pair.new([array1, array2], nil, nil, 0)
    new_pair.reduce
    new_pair
  end
end


file = File.open("input.txt")
all_input = file.readlines.map { |line| line.gsub("\n", '') }.map { |line| JSON.parse line }

# PART 1
tmp = Pair.new(all_input[0], nil, nil, 0)
[*1..all_input.length - 1].each do |i|
  pair_to_add = Pair.new(all_input[i], nil, nil, 0)
  tmp = tmp.add(pair_to_add)
end
#p tmp.compute_array 
p tmp.compute_magnitude # Solution

# PART 2
all_magnitudes = []
[*0..all_input.length - 2].each do |i|
  pair1 = Pair.new(all_input[i], nil, nil, 0)
  [*i + 1..all_input.length - 1].each do |j|
    pair2 = Pair.new(all_input[j], nil, nil, 0)
    sum_pair1 = pair1.add(pair2)
    sum_pair2 = pair2.add(pair1)
    all_magnitudes.push(sum_pair1.compute_magnitude)
    all_magnitudes.push(sum_pair2.compute_magnitude)
  end
end

p all_magnitudes.max 
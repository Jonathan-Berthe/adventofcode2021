file = File.open("input.txt")
array = file.readlines.map { |e| e.gsub("\n","") }

def opening_char?(char)
  char == "(" || char == "[" || char == "{" || char == "<"
end

def closing_char?(char)
  char == ")" || char == "]" || char == "}" || char == ">"
end

def corresponding_pair(char)
  case char
  when ")"
    "("
  when "]"
    "["
  when "}"
    "{"
  when ">"
    "<"
  end
end

def find_first_corrupted_character_or_incomplete_array(line)
  stack = []
  line.each_char do |char|
    if opening_char?(char)
      stack.push(char) 
      next
    elsif closing_char?(char) && corresponding_pair(char) != stack.last
      return char
    elsif closing_char?(char) && corresponding_pair(char) == stack.last
      stack.pop
    else
      raise "Error"
    end
  end
  stack
end

def error_score(character)
  case character
  when ")"
    3
  when "]"
    57
  when "}"
    1197
  when ">"
    25137
  end
end

def completion_score(array)
  total = 0
  array.reverse.each do |e|
    total *= 5
    case e
    when "("
      total += 1
    when "["
      total += 2
    when "{"
      total += 3
    when "<"
      total += 4
    end
  end
  total
end

def run(array)
  out1 = [] # For Part 1
  out2 = [] # For Part 2
  array.each_with_index do |line, i|
    character_or_array = find_first_corrupted_character_or_incomplete_array(line)
    if character_or_array.kind_of?(Array)
      out2.push(completion_score(character_or_array))
    else
      out1.push(character_or_array)
    end
  end
  p out1.map { |e| error_score(e) }.sum # Solution Part 1
  p out2.sort[(out2.length / 2).floor] # Solution Part 2
end

run(array)
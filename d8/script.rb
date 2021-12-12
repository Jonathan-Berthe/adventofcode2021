file = File.open('input.txt')
array = file.readlines.map do |e|
  e.split(' | ').map { |str| str.gsub(/\n/, '').split(' ') }
end
outputs = array.map { |e| e[1] }

# Part 1

def count_unique_in_output(output)
  output.count do |e|
    l = e.length
    [2, 3, 4, 7].include? l
  end
end

def part1(outputs)
  count = 0
  outputs.each { |e| count += count_unique_in_output(e) }
  count
end

p part1(outputs)

# Part 2

def count_in_common(d1, d2)
  return 0 if (d1.is_a? Integer) || (d2.is_a? Integer)

  count = 0
  d2.each_char do |c|
    count += 1 if d1.include?(c)
  end
  count
end

def algo_array(array, old_tab)
  tab = old_tab
  new_array = array.map do |e|
    out = e
    l = e.to_s.length
    tab.each do |k, v|
      if count_in_common(v, e) == l
        out = k.to_i
        break
      end
    end
    if tab.key?('1')
      in_common = count_in_common(tab['1'], e)
      if in_common == 2 && l == 5
        tab['3'] = e
        out = 3
      end
    end
    if tab.key?('2')
      in_common = count_in_common(tab['2'], e)
      if in_common == 4 && l == 5
        tab['3'] = e
        out = 3
      end
      if in_common == 3 && l == 5
        tab['5'] = e
        out = 5
      end
    end
    if tab.key?('3')
      in_common = count_in_common(tab['3'], e)
      if in_common == 5 && l == 6
        tab['9'] = e
        out = 9
      end
    end
    if tab.key?('4')
      in_common = count_in_common(tab['4'], e)
      if in_common == 2 && l == 5
        tab['2'] = e
        out = 2
      end
      if in_common == 4 && l == 6
        tab['9'] = e
        out = 9
      end
    end
    if tab.key?('5')
      in_common = count_in_common(tab['5'], e)
      if in_common == 4 && l == 6
        tab['0'] = e
        out = 0
      end
      if in_common == 3 && l == 5
        tab['2'] = e
        out = 2
      end
      if in_common == 4 && l == 5
        tab['3'] = e
        out = 3
      end
    end
    if tab.key?('6')
      in_common = count_in_common(tab['6'], e)
      if in_common == 5 && l == 5
        tab['5'] = e
        out = 5
      end
    end
    if tab.key?('7')
      in_common = count_in_common(tab['7'], e)
      if in_common == 2 && l == 6
        tab['6'] = e
        out = 6
      end
      if in_common == 3 && l == 5
        tab['3'] = e
        out = 3
      end
    end
    if tab.key?('9')
      in_common = count_in_common(tab['9'], e)
      if in_common == 4 && l == 5
        tab['2'] = e
        out = 2
      end
    end
    if l == 6 && tab.key?('0') && count_in_common(tab['0'], e) != 6 && tab.key?('6') && count_in_common(tab['6'], e) != 6
      tab['9'] = e
      out = 9
    end
    if l == 6 && tab.key?('0') && count_in_common(tab['0'], e) != 6 && tab.key?('9') && count_in_common(tab['9'], e) != 6
      tab['6'] = e
      out = 6
    end
    if l == 6 && tab.key?('6') && count_in_common(tab['6'], e) != 6 && tab.key?('9') && count_in_common(tab['9'], e) != 6
      tab['0'] = e
      out = 0
    end
    if l == 5 && tab.key?('2') && count_in_common(tab['2'], e) != 5 && tab.key?('3') && count_in_common(tab['3'], e) != 5
      tab['5'] = e
      out = 5
    end
    if l == 5 && tab.key?('2') && count_in_common(tab['2'], e) != 5 && tab.key?('5') && count_in_common(tab['5'], e) != 5
      tab['3'] = e
      out = 3
    end
    if l == 5 && tab.key?('3') && count_in_common(tab['3'], e) != 5 && tab.key?('5') && count_in_common(tab['5'], e) != 5
      tab['2'] = e
      out = 2
    end
    out
  end
  [new_array, tab]
end

def decrypt(input, output)
  array = [*input, *output]
  tab = {}
  array = array.map do |e|
    out = e
    case e.length
    when 2
      tab['1'] = e
      out = 1
    when 3
      tab['7'] = e
      out = 7
    when 4
      tab['4'] = e
      out = 4
    when 7
      tab['8'] = e
      out = 8
    end
    out
  end
  algo = algo_array(array, tab)
  array = algo[0]
  tab = algo[1]
  array
end

def part2(array)
  sum = array.map do |e|
    input = e[0]
    output = e[1]
    decrypt_array = decrypt(input, output)
    secret = decrypt_array.slice(-4, 4).join.to_i
    secret
  end.sum
end

p part2(array)

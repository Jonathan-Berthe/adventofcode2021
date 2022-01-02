def process(w_array)
  # Coefs x1, x2, x3, x4 for all steps
  tmp = [[1, 10, 25, 13], [1, 13, 25, 10], [1, 13, 25, 3], [26, -11, 25, 1], [1, 11, 25, 9], [26, -4, 25, 3], [1, 12, 25, 5], [1, 12, 25, 1], [1, 15, 25, 0], [26, -2, 25, 13], [26, -5, 1, 7], [26, -11, 25, 15], [26, -13, 25, 12], [26, -10, 25, 8]]
  z = 0
  w_accum = []
  [*0..13].each do |i|
    w = w_array[i].to_i
    x1, x2, x3, x4 = tmp[i]
    if x1 == 26
      w = (z % 26) + x2
      return -1 if w < 1 || w > 9
      z = (z / 26)
    else
      z = (z / x1)*(x3 + 1) + (w + x4)
    end
    w_accum.push(w)
  end
  [z, w_accum]
end

# part2 of the exercice or not (set to true or false)
part2 = false

w_combinaison = part2 ? 1111111 : 9999999
w_answer = nil
loop do
  nbr = w_combinaison.to_s.split("")
  if nbr.include?("0")
    w_combinaison = part2 ? w_combinaison + 1 : w_combinaison - 1
    next
  end
  numbers = [nbr[0], nbr[1], nbr[2], nil, nbr[3], nil, nbr[4], nbr[5], nbr[6], nil, nil, nil, nil, nil]
  z, w = process(numbers)
  if z == 0
    w_answer = w
    break
  end
  w_combinaison = part2 ? w_combinaison + 1 : w_combinaison - 1

  next_step = part2 ? w_combinaison <= 9999999 : w_combinaison >= 1111111
  break unless next_step

end

# Response
p w_answer


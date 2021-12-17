
# input - don't need to parse it from a file today :)
target = [[57, 116], [-198, -148]]
y_target_min = target[1][0]

# PART 1 - Analytic solution
# We have:
# v_y(t) = v_0y - t (by recurrence)
# y(t) = y(t-1) + v(t-1) = t*v_0y - sum(i, from i=1 to i=t-1) = t*v_0y - (t*(t-1)/2) (by recurrence)
# => y_max at t_max = v_0 because v_y,max = 0 at this point
# => y = 0 at t_0 = 2*V_0 because of the symetry with (0,0) origin point with the maximum point at t_max
# => because of symetry again, v_y(t_0) = - v_0y
# => v_0y can't be > to |y_min| because if so we'll have y(t_0 + 1) = y(t_0) - v(t_0) = 0 - v_0y < y_min and so we are outside of the target
# ==> So the max v_oy (which lead to the max y height) is |y_min| and there, because t = v_0y = t_min we'll have the y_max bellow !

y_max = ((y_target_min**2) - y_target_min.abs) / 2
p y_max

# PART 2 - kind of brute force...
def check_all_point(target)
  x_target = target[0]
  x_min = x_target[0]
  x_max = x_target[1]
  y_target = target[1]
  y_min = y_target[0]
  y_max = y_target[1]
  count = 0
  # v_ox can't be < 1 and > x_max to be in the target
  [*1..x_max].each do |v_x|
    # v_oy can't be outside of the intervalle [-|y_min|, |y_min|]
    [*y_min..-y_min].each do |v_y|
      if in_target?(v_x, v_y, x_min, x_max, y_min, y_max)
        count += 1
      end
    end
  end
  count
end

def in_target?(v_x0, v_y0, x_min, x_max, y_min, y_max)
  x = 0
  y = 0
  v_x = v_x0
  v_y = v_y0
  check = false
  while x <= x_max && y >= y_min
    if x >= x_min && y <= y_max
      check = true
      break
    end
    x += v_x
    y += v_y
    v_y -= 1
    if v_x > 0
      v_x -= 1
    end
  end
  check
end

p check_all_point(target)

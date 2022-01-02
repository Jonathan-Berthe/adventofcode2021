if we analyse machine of the input, we see that we have 14 times the same process which depend of 4 parameters x1, x2, x3 and x4, of z_d (value of z at the end of the previous process, or 0 for the first process) and of w (input digit of the step). In addition, x and y are reset to 0 and so are "temporary" variables (process doesn't depend of x and y values of the previous step). Here is the machine instructions of 1 step:

```
inp w
mul x 0
add x z_d
mod x x1
div z 1
add x x2
eql x w
eql x 0
mul y 0
add y x3
mul y x
add y 1
mul z y
mul y 0
add y w
add y x4
mul y x
add z y
```

We can simplify the process with these equations of z_f (value of z after the process):

```
z_f = floor(z_d / x1) if w == (z_d % 26) + x2
z_f = floor(z_d / x1)*(x3 + 1) + (w + x4) if w != (z_d % 26) + x2
```

Corresponding values of (x1,x2,x3,x4) for all of the 14 processes are:

[[1, 10, 25, 13], [1, 13, 25, 10], [1, 13, 25, 3], [26, -11, 25, 1], [1, 11, 25, 9], [26, -4, 25, 3], [1, 12, 25, 5], [1, 12, 25, 1], [1, 15, 25, 0], [26, -2, 25, 13], [26, -5, 1, 7], [26, -11, 25, 15], [26, -13, 25, 12], [26, -10, 25, 8]]

If we want to process in the machine a number [w1, w2, ..., w14] => We simply have to apply these equations by recurrence starting with z_d = 0 in the first step.

Some observations:

- In all processes, we have either x1 = 26 or x1 = 1. 
- When we have x1 = 1, x2 is always > 10. So we'll have w != (z % 26) + x2 because w is in [1, 9] and (z % 26) + x2 >= x2 > 10.
- Because of the previous point, z_f value of a step with x1 = 1 will depend of the input digit w. In addition, we always have x3 = 25 when x1 = 1. So the equation become:
 ```
 z_f = 26z_d + (w + x4)
 ```
Last but not least, w + x4 will always be < 26 when x1 = 1. And so in the equation above, floor(z_f / 26) = z_d
- when w != (z_d % 26) + x2, z_f will be much bigger than z_d because of the positive factor (x3 + 1). So if we want z = 0 in the end of the last process, we should have some of the steps which are with w == (z % 26) + x2, to descrease the value of z at some points. 
- ==> HYPOTHESIS: z = 0 at the end of the machine only if we have w == (z % 26) + x2 for steps with x1 = 26. So in the algo, we'll fix the value of w to the one which match the condition to ensure we are in a decreasing step. Intuitively, as we have 7 steps with x1 = 1 where we have floor(z_f / 26) = z_d (see 3e point above), we should have at least 7 others steps where z_f = floor(z_d / 26) if we want to vanish the "increase" caused by steps where x1 = 1. And as there are 7 steps with x1 = 21 => all of them must match the condition.
- Algo based on the hypothesis of the previous point: we test the machine (so all 14 steps) for all values of w for input digit corresponding to the steps where x1 = 1, and all the others w values are calculed to match the condition for steps where x1 = 26. Sometimes there is no w value for which a condition is satisfied and so we test the next w combinaison. => There is 7 steps with x1 = 1, so we have (in worst case) 9^7 differents combinaisons to test. This is much better than testing all possible w input combinaisons (9^14) ! If we want to find the biggest combinaison of w for which z = 0 as output of the machine, we have to start with 9999999, then 9999998, then 9999997.... until we have z = 0 and we stop the algo ! To find the lowest combinaison => we start with 1111111, then 1111112, 1111113...


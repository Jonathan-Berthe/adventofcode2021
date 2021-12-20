class ImageScanner
  attr_accessor :image, :m, :n, :value_infinite

  def initialize(algo, input)
    @algo = algo
    @image = input
    @m = input.length
    @n = input[0].length
    # The values of pixels inside the "infity grid" are either 0 or 1 depending on the enhancement of these pixels from the previous step. Before the first step, this value is 0 (dark)
    @value_infinite = 0
  end

  # Compute all 9 pixels related to pixel [i,j] and return the decimal associated code.
  def nine_pixels_code(pixel, copy_image)
    pos_i = pixel[0]
    pos_j = pixel[1]
    out = []
    [*-1..1].each do |i|
      tmp = []
      [*-1..1].each do |j|       
        x = pos_i + i
        y = pos_j + j
        if x < 0 || x > m - 1 || y < 0 || y > n - 1
          tmp.push(value_infinite)
        else
          tmp.push(copy_image[x][y])
        end
      end
      out.push(tmp)
    end
    out.flatten.join('').to_i(2)
  end

  def algo(index)
    @algo[index]
  end

  # enhance pixel [i, j]
  def update_pixel(pixel, copy_image)
    code_index = nine_pixels_code(pixel, copy_image)
    x = pixel[0]
    y = pixel[1]
    new_value = algo(code_index)
    @image[x][y] = new_value unless x < 0 || x > m - 1 || y < 0 || y > n - 1
    algo(code_index)
  end

  # We "grow" the image by surrounding the image with the pixel value of infinity grid
  def grow_image
    image.each do |line|
      line.unshift(value_infinite)
      line.push(value_infinite)
    end
    @m = m + 2
    image.unshift(Array.new(m, value_infinite))
    image.push(Array.new(m, value_infinite))
    @n += 2
  end

  def count_lit
    tmp = 0
    image.each do |line|
      line.each do |pixel|
        tmp += pixel
      end
    end
    tmp
  end

  def step(n)
    n.times do
      grow_image
      #We use copy_image, a deep dup copy of @image, instead of the variable instance @image because we need to do all the enhancement simultanously for all pixels and so we don't want our image input change during the algo
      copy_image = []
      image.each do |line|
        copy_image.push(line.dup)
      end
      image.each_with_index do |line, i|
        line.each_with_index do |_, j|
          update_pixel([i,j], copy_image)
        end
      end
      # Update of the reference value of pixels inside the "infity grid", with the result of the update of a pixel outside our image
      @value_infinite = update_pixel([-2,-2],copy_image)
    end
  end
end


# Parsing
file = File.open("input.txt")
array = file.readlines.map { |line| line.gsub("\n","") }.map do |line|
  new_line = Array.new(line.length, 0)
  line.each_char.with_index do |e, i|
    new_line[i] = 1 if e == "#"
  end
  new_line
end

image_algo = array[0]
input_image = array[2..array.length-1]
image = ImageScanner.new(image_algo, input_image)

# Part 1
#image.step(2)

# Part 2
image.step(50)
p image.count_lit

require_relative 'require'



Point = Struct.new(:x, :y, :color)

Bounds = Struct.new(:min_x, :min_y, :max_x, :max_y) do
  def x
    max_x - min_x
  end
  def y
    max_y - min_y
  end
end



# Load the 'brush' used to mark each dispatch
gradient = Magick::Image.read('gradient.png')[0]

# Image filename
output_file = 'dispatches.png'

h = 3800 # width of image
w = 5000 # height of image
d = gradient.base_rows # diameter of radial gradient
r = d / 2 # radius of radial gradient
c = 0.5 # colorize percent

bg_color = '#000'

# Different color for each dispatch's agency_id.
colors = %w(
  #6cf
  #6ff
  #f9f
  #f99
  #cf9
  #9cf
  #f9c
  #c9f
  #ff9
  #fc9
  #fff
  #9fc
  #9f9
)



# Fetch points from the dispatches database
points = PDX911::Database.query(
  "SELECT agency_id AS a , location[0] AS y, location[1] AS x FROM dispatches ORDER BY date DESC"
).map do |pix|
  Point.new pix['x'].to_f, pix['y'].to_f, colors[pix['a'].to_i - 1]
end



# Calculate the bounds of the latitude and longitude
bounds = points.reduce(Bounds.new(10000, 10000, -10000, -10000)) do |memo, pix|
  memo.min_x = pix.x if pix.x < memo.min_x
  memo.max_x = pix.x if pix.x > memo.max_x
  memo.min_y = pix.y if pix.y < memo.min_y
  memo.max_y = pix.y if pix.y > memo.max_y
  memo
end



# Create a blank, black canvas
canvas = Magick::Image.new(w+d, h+d, Magick::GradientFill.new(0, 0, 0, 0, bg_color, bg_color))

# Paint each dispatch by compositing a colorized version of the 'brush' image onto the canvas
points.each do |pix|
  x = ((pix.x - bounds.min_x) / bounds.x * w) + r
  y = ((1 - (pix.y - bounds.min_y) / bounds.y) * h) + r
  canvas.composite! gradient.colorize(c,c,c,0,pix.color), x+r, y+r, Magick::PlusCompositeOp
end

# Save the file
canvas.write output_file
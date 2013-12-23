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

height = 1500
width  = 2200
radius = 3

colors = %w(
  6cf
  6ff
  f9f
  f99
  cf9
  9cf
  f9c
  c9f
  ff9
  fc9
  fff
  9fc
  9f9
)



pixels = PDX911::Database.query("SELECT agency_id AS a , location[0] AS y, location[1] AS x FROM dispatches ORDER BY date DESC")

pixels.map! do |pix|
  Point.new pix['x'].to_f, pix['y'].to_f, pix['a'].to_i - 1
end



bounds = pixels.reduce(Bounds.new(10000, 10000, -10000, -10000)) do |memo, pix|
  memo.min_x = pix.x if pix.x < memo.min_x
  memo.max_x = pix.x if pix.x > memo.max_x
  memo.min_y = pix.y if pix.y < memo.min_y
  memo.max_y = pix.y if pix.y > memo.max_y
  memo
end



canvas = Magick::Image.new(width, height, Magick::GradientFill.new(0, 0, 0, 0, '#000', '#000'))
gc = Magick::Draw.new

pixels.each do |pix|
  x = (pix.x - bounds.min_x) / bounds.x * width
  y = (1 - (pix.y - bounds.min_y) / bounds.y) * height
  # gradient_image = Magick::Image.new(width, height, Magick::GradientFill.new(x1, y1, x2, y2, start_color, end_color))
  gc.fill "##{colors[pix.color]}8"
  gc.point x, y
end

gc.draw canvas
canvas.write 'foo.png'
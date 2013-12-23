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

height = 500
width  = 1000

colors = %w(
  #00F
  #0F0
  #F00
  #FF0
  #0FF
  #F0F
  #000
  #000
  #000
  #000
  #000
)



pixels = PDX911::Database.query("SELECT agency_id AS a , location[0] AS x, location[1] AS y FROM dispatches ORDER BY date DESC")

pixels.map! do |pix|
  Point.new pix['x'].to_f, pix['y'].to_f, colors[pix['a'].to_i]
end



bounds = pixels.reduce(Bounds.new(10000, 10000, -10000, -10000)) do |memo, pix|
  memo.min_x = pix.x if pix.x < memo.min_x
  memo.max_x = pix.x if pix.x > memo.max_x
  memo.min_y = pix.y if pix.y < memo.min_y
  memo.max_y = pix.y if pix.y > memo.max_y
  memo
end



canvas = Magick::Image.new(width, height)
gc = Magick::Draw.new


gc.fill '#000'

gc.rectangle(0, 0, width, height) 

pixels.map do |pix|
  gc.fill pix.color
  x = (pix.x - bounds.min_x) / bounds.x * width
  y = (pix.y - bounds.min_y) / bounds.y * height
  gc.point x, y
end

gc.draw canvas
canvas.write 'foo.png'
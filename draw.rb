require_relative 'require'

Pixel = Struct.new(:color, :x, :y)

Bounds = Struct.new(:min_x, :min_y, :max_x, :max_y) do
  def width
    max_x - min_x
  end
  def height
    max_y - min_y
  end
end

scale_x = 300
scale_y = 100



pixels = PDX911::Database.query("SELECT agency_id AS a , location[0] AS x, location[1] AS y FROM dispatches ORDER BY date DESC")

pixels.map! do |pix|
  Pixel.new pix['a'].to_i,
    (pix['x'].to_f * scale_x).floor,
    (pix['y'].to_f * scale_y).floor
end



bounds = pixels.reduce(Bounds.new(10000, 10000, -10000, -10000)) do |memo, pix|
  memo.min_x = pix.x if pix.x < memo.min_x
  memo.max_x = pix.x if pix.x > memo.max_x
  memo.min_y = pix.y if pix.y < memo.min_y
  memo.max_y = pix.y if pix.y > memo.max_y
  memo
end



canvas = Magick::Image.new(bounds.width, bounds.height)
gc = Magick::Draw.new

gc.fill("rgba(0,0,0,255)")

pixels.map do |pix|
  gc.point(pix.x - bounds.min_x, pix.y - bounds.min_y)
end

gc.draw canvas
canvas.write 'foo.png'
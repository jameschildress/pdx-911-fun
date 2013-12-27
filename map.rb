require_relative 'pdx911/pdx911'



# Ready the blank image canvas
image_name       = 'dispatches.png'
image_height     = 2000 # width of image
image_width      = 3000 # height of image
image_bg_color   = '#000'
canvas           = Magick::Image.new(image_width, image_height, Magick::GradientFill.new(0, 0, 0, 0, image_bg_color, image_bg_color))

# Properties of the bar chart at the bottom of the image
bar_padding      = 20
bar_height       = 1

# Different color for each dispatch's agency_id
colors = Hash.new('#AAA').merge({
  1 => '#f70',  # Portland Police
  0 => '#f51',  # Gresham Police
  2 => '#f04',  # Fairview Police
  5 => '#fc3',  # Troutdale Police
  7 => '#fc3',  # Airport Police
  6 => '#0ff',  # Portland Fire
  3 => '#0f7',  # Gresham Fire
  8 => '#37f',  # Airport Fire
  4 => '#f0f',  # Multnomah County Sheriff
})         



# MAP OF DISPATCHES ===================================================

# Load the 'brush' used to mark each dispatch
brush            = Magick::Image.read('gradient.png')[0]
brush_diameter   = brush.base_rows # diameter of radial gradient
brush_radius     = brush_diameter / 2 # radius of radial gradient
colorize_percent = 0.5 # colorize percent

# Set the bounds to an arbitrary frame
bounds = PDX911::Bounds.new(-122.800, 45.635, -122.320, 45.414)

# Paint each dispatch by compositing a colorized version of the 'brush' image onto the canvas
PDX911::Dispatches.each do |dispatch|
  x = ((dispatch.x - bounds.min_x) / bounds.width * image_width) + brush_radius
  y = ((dispatch.y - bounds.min_y) / bounds.height * image_height) + brush_radius
  color = colors[dispatch.agency_id - 1]
  this_brush = brush.colorize(colorize_percent, colorize_percent, colorize_percent, 0, color)
  canvas.composite! this_brush, x + brush_radius, y + brush_radius, Magick::PlusCompositeOp
end



# AGENCY CHART ========================================================

# Get the total number of dispatches
total_dispatches = PDX911::Agencies.reduce(0) do |memo, agency|
  memo += agency.dispatch_count
end

# Paint the bar chart at the bottom of the image
x          = bar_padding
max_x      = image_width - ((PDX911::Agencies.count + 1) * bar_padding)
bar_bottom = image_height - bar_padding
bar_top    = bar_bottom - bar_height

gc = Magick::Draw.new

PDX911::Agencies.each do |agency|
  width = (agency.dispatch_count.to_f / total_dispatches.to_f) * max_x
  color = colors[agency.id - 1]
  gc.fill "#{color}6"
  gc.rectangle x, bar_top, x + width, bar_bottom
  x = x + width + bar_padding
end



# Save the file
gc.draw canvas
canvas.write image_name
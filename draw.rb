require_relative 'pdx911/pdx911'

# Load the 'brush' used to mark each dispatch
gradient = Magick::Image.read('gradient.png')[0]

# Image filename
output_file = 'dispatches.png'

h = 3500 # width of image
w = 5000 # height of image
d = gradient.base_rows # diameter of radial gradient
r = d / 2 # radius of radial gradient
c = 0.5 # colorize percent

bg_color = '#000'

# Different color for each dispatch's agency_id.
colors = Hash.new('#AAAAAA').merge({
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

# Set the bounds to an arbitrary frame.
bounds = PDX911::Bounds.new(-122.800, 45.635, -122.320, 45.414)

# Create a blank, black canvas
canvas = Magick::Image.new(w+d, h+d, Magick::GradientFill.new(0, 0, 0, 0, bg_color, bg_color))

# Paint each dispatch by compositing a colorized version of the 'brush' image onto the canvas
PDX911::Dispatches.each do |dispatch|
  x = ((dispatch.x - bounds.min_x) / bounds.width * w) + r
  y = ((dispatch.y - bounds.min_y) / bounds.height * h) + r
  color = colors[dispatch.agency_id - 1]
  canvas.composite! gradient.colorize(c,c,c,0,color), x+r, y+r, Magick::PlusCompositeOp
end

# Save the file
canvas.write output_file
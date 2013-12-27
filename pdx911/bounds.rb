module PDX911
  Bounds = Struct.new(:min_x, :min_y, :max_x, :max_y) do
    
    def width
      max_x - min_x
    end
    
    def height
      max_y - min_y
    end
    
  end
end
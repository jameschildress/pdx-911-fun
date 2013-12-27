module PDX911
  class Dispatch
    
    attr_reader :x, :y, :agency_id, :category_id
    
    def initialize x, y, agency_id, category_id
      @x = x.to_f
      @y = y.to_f
      @agency_id = agency_id.to_i
      @category_id = category_id.to_i
    end
    
  end
  
  

  # Fetch dispatches from the database
  Dispatches = PDX911::Database.query(
    "SELECT category_id AS c, agency_id AS a, location[0] AS y, location[1] AS x FROM dispatches ORDER BY date DESC"
  ).map do |result|
    Dispatch.new result['x'], result['y'], result['a'], result['c']
  end
  
end




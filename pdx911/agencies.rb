module PDX911
  class Agency
    
    attr_reader :id, :name, :dispatch_count
    
    def initialize id, name, dispatch_count
      @id = id.to_i
      @name = name
      @dispatch_count = dispatch_count.to_i
    end
    
  end
  
  

  # Fetch dispatches from the database
  Agencies = PDX911::Database.query(
    <<-sql
      SELECT    count(*), agencies.name, agencies.id
      FROM      dispatches, agencies
      WHERE     dispatches.agency_id = agencies.id
      GROUP BY  agencies.name, agencies.id
      ORDER BY  count DESC
    sql
  ).map do |result|
    Agency.new result['id'], result['name'], result['count']
  end
  
end




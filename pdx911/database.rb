module PDX911
  class Database
    
    CONNECTION_SETTINGS = {
      host:     'localhost',
      dbname:   ENV['PDX911_DATABASE_NAME'],
      user:     ENV['PDX911_READONLY_DATABASE_USER'],
      password: ENV['PDX911_READONLY_DATABASE_PASSWORD']
    }
    
    def self.query sql, *params
      db = PG::Connection.open(CONNECTION_SETTINGS)
      result = db.exec_params(sql, params)
      db.close
      result.to_a
    end
  
  end
end
require_relative 'require'

dispatches = PDX911::Database.query("SELECT category_id AS c , location[0] AS x, location[1] AS y FROM dispatches ORDER BY date DESC")


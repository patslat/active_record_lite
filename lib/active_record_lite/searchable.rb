require_relative './db_connection'

module Searchable
  def where(params)
    attributes = params.map { |key, val| "#{key} = ?" }.join(" AND ")
    values = params.values
    query = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{attributes}
    SQL
    targets = DBConnection.execute(query, *values)
    targets.map { |row| self.new(row) }
  end
end
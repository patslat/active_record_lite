require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject
  extend Searchable
  extend Associatable
  
  def self.set_table_name(table_name)
    @table_name = table_name.underscore
  end

  def self.table_name
    @table_name
  end

  def self.all
    DBConnection.execute("
    SELECT *
    FROM #{table_name}
    ").map { |row| new(row) }
  end

  def self.find(id)
    object =
    DBConnection.execute("
    SELECT *
    FROM #{table_name}
    WHERE id = #{id}
    ").first
    new(object)
  end
  
  def save
    id ? update : create
  end


  private

  def create
    attributes = self.class.attributes.join(", ")
    qmarks = (['?'] * self.class.attributes.length).join(", ")
    query = <<-SQL
      INSERT INTO #{self.class.table_name}
    (#{ attributes }) VALUES
    (#{ qmarks })
    SQL

    DBConnection.execute(query, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    query = <<-SQL
    UPDATE #{self.class.table_name}
    SET #{set_line}
    WHERE id = #{self.id}
    SQL
    DBConnection.execute(query, *attribute_values)
  end

  def attribute_values
    self.class.attributes.map { |attr| self.send(attr) }
  end
  
  def set_line
    self.class.attributes.map { |attribute| "#{attribute} = ?" }.join(", ")
  end
end
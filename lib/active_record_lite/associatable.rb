require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    define_method(name) do
      other_class = if params[:class_name]
                      params[:class_name].constantize
                    else
                      name.to_s.camelcase.constantize
                    end

      other_table_name = other_class.table_name
      primary_key = params[:primary_key] || :id
      foreign_key = params[:foreign_key] || "#{name}_id".to_sym
      
      query = <<-SQL
                SELECT DISTINCT #{other_table_name}.*
                FROM #{self.class.table_name}
                JOIN #{other_table_name}
                ON #{self.class.table_name}.#{primary_key} = #{foreign_key}
              SQL
      results = DBConnection.execute(query)
      other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    define_method(name) do
      other_class = params[:class_name] || name.to_s.singularize.camelcase.constantize
      other_table_name = other_class.table_name
      primary_key = params[:primary_key] || :id
      foreign_key = params[:foreign_key] || "#{name}_id".to_sym
      
      query = <<-SQL
                SELECT DISTINCT #{other_table_name}.*
                FROM #{self.class.table_name}
                JOIN #{other_table_name}
                ON #{self.class.table_name}.#{primary_key} = #{foreign_key}
              SQL
              
      results = DBConnection.execute(query)
      other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end

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
  attr_reader :other_class, :other_table, :primary_key, :foreign_key
  def initialize(name, params)
    @other_class = if params[:class_name]
                    params[:class_name].constantize
                  else
                    name.to_s.camelcase.constantize
                  end
    @other_table = other_class.table_name
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
  end
      
  def type
  end 
end   
      
class HasManyAssocParams < AssocParams
  attr_reader :other_class, :other_table, :primary_key, :foreign_key
  def initialize(name, params, self_class)
      @other_class = params[:class_name] || name.to_s.singularize.camelcase.constantize
      @other_table = other_class.table_name
      @primary_key = params[:primary_key] || :id
      @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
    end
      
  def type
  end 
end   
      
module Associatable
  def assoc_params
  end 
      
  def belongs_to(name, params = {})
    define_method(name) do
      bt = BelongsToAssocParams(name, params)
      
      query = <<-SQL
                SELECT DISTINCT #{bt.other_table}.*
                FROM #{self.class.table_name}
                JOIN #{bt.other_table}
                ON #{self.class.table_name}.#{bt.primary_key} = #{bt.foreign_key}
              SQL
              
      results = DBConnection.execute(query)
      bt.other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    define_method(name) do
      aps = HasManyAssocParams.new(name, params, self.class)
      
      query = <<-SQL
                SELECT DISTINCT #{aps.other_table}.*
                FROM #{self.class.table_name}
                JOIN #{aps.other_table}
                ON #{self.class.table_name}.#{aps.primary_key} = #{aps.foreign_key}
              SQL
              
      results = DBConnection.execute(query)
      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end

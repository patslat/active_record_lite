require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class.constantize
  end

  def other_table
    @other_class.constantize.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :primary_key, :foreign_key
  def initialize(name, params)
    @other_class = params[:class_name] || name.to_s.camelcase
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
  end
      
  def type
  end 
end   
      
class HasManyAssocParams < AssocParams
  attr_reader :primary_key, :foreign_key
  def initialize(name, params, self_class)
      @other_class = params[:class_name] || name.to_s.singularize.camelcase
      @primary_key = params[:primary_key] || :id
      @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
  end
      
  def type
  end 
end   
      
module Associatable
  def assoc_params
    @assoc_params ||= {}
  end
      
  def belongs_to(name, params = {})
    bt = BelongsToAssocParams.new(name, params)
    assoc_params[name] = bt
    define_method(name) do 

      query = <<-SQL
                SELECT DISTINCT #{bt.other_table}.*
                FROM #{bt.other_table}
                WHERE #{self.id} = #{bt.primary_key}
              SQL
              
      results = DBConnection.execute(query)
      bt.other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self.class)
    assoc_params[name] = aps
    
    define_method(name) do
      query = <<-SQL
                SELECT DISTINCT #{aps.other_table}.*
                FROM #{aps.other_table}
                WHERE #{aps.primary_key} = #{self.id}
              SQL
              
      results = DBConnection.execute(query)
      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)

    through = assoc_params[assoc1]
    has_one = BelongsToAssocParams.new(name, {})
    assoc_params[name] = has_one
    define_method(name) do

      query = <<-SQL
        SELECT #{has_one.other_table}.*
        FROM #{has_one.other_table}
        JOIN #{through.other_table}
        ON #{through.other_table}.#{through.primary_key} = #{has_one.other_table}.#{has_one.primary_key}
        WHERE #{through.other_table}.#{through.primary_key} = #{self.id}
      SQL
      
      results = DBConnection.execute(query)
      has_one.other_class.parse_all(results)
    end
  end
end
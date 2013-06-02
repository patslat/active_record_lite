class Object
  def new_attr_accessor(*attributes)
    attributes.each do |attr_name|
      define_method(attr_name) do
        instance_variable_get("@#{attr_name}".to_sym)
      end
      
      define_method("#{attr_name}=") do |val|
        instance_variable_set("@#{attr_name}", val)
      end
    end
  end
end

class MassObject
  
  def self.set_attrs(*attributes)
    @attributes = attributes
    new_attr_accessor(*attributes)
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |row| new(row) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.attributes.include?(attr_name.to_sym)
        raise "mass assignment to unregistered attribute #{attr_name.to_sym}"
      end
      send("#{attr_name}=".to_sym, value)
    end
  end
end

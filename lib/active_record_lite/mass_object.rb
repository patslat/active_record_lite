class MassObject
  def self.set_attrs(*attributes)
    @attributes = attributes
    attributes.each { |attr_name| attr_accessor(attr_name) }
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.attributes.include?(attr_name)
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
      send("#{attr_name}=".to_sym, value)
    end
  end
end

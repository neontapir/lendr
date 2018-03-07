require_relative '../entity.rb'

class Event < Entity
  attr_reader :type

  def initialize()
    super
  end

  def update(projection, transform)
    raise NotFoundError unless transform.key? :@timestamp
    transform.each do |key, value|
      projection.instance_variable_set(key, value)
    end
  end
end

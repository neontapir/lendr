# frozen_string_literal: true

require_relative '../entity.rb'

class Event < Entity
  attr_reader :type

  def initialize
    super
  end

  def update(projection, transform)
    raise NotFoundError, 'All entity changes should update the timestamp, but this one does not' unless transform.key? :@timestamp
    transform.each do |key, value|
      projection.instance_variable_set key, value
    end
  end

  def to_s
    variables = instance_variables.map do |v|
      "#{v}: #{instance_variable_get(v.to_s)}"
    end.join(', ')
    "{ #{self.class}: #{variables} }"
  end
end

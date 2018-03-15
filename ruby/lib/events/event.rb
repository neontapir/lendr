# frozen_string_literal: true

require_relative '../entity.rb'

class Event < Entity
  attr_reader :type

  def initialize
    super
  end

  def self.dispatch(**entities)
    unless entities.is_a?(Hash) &&
           entities.keys.sort == instance_method(:initialize).parameters.map(&:last).sort
      raise 'Dispatch arguments must match event initializer signature'
    end
    event = new(**entities)
    entities.each_value do |entity|
      entity.update_timestamp event.timestamp
    end
    EventStore.store event
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

# frozen_string_literal: true

require_relative '../domain/entity.rb'

class Event < Entity
  def self.dispatch(**entities)
    unless entities.is_a?(Hash) &&
           entities.keys.sort == entity_list
      raise 'Dispatch arguments must match event initializer signature'
    end
    event = new(**entities)
    entities.each_value do |entity|
      entity.update_timestamp event.timestamp
    end
    EventStore.store event
  end

  def self.any?(**entities)
    EventStore.instance.any? do |event|
      event.is_a?(self) &&
        entity_list.all? { |e| event.send(e).id == entities[e].id }
    end
  end

  def self.entity_list
    instance_method(:initialize).parameters.map(&:last).sort
  end

  def update(projection, transform)
    raise NotFoundError, 'All entity changes should update the timestamp, but this one does not' unless transform.key? :@timestamp
    transform.each do |key, value|
      projection.instance_variable_set key, value
    end
  end
end

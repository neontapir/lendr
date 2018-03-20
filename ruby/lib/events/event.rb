# frozen_string_literal: true

require_relative '../domain/entity.rb'
require_relative '../event_store.rb'

class Event < Entity
  attr_reader :entities

  def initialize(**entities)
    super()
    @entities = entities
    entities.each_key do |entity|
      self.class.define_method(entity) do
        @entities[entity]
      end
    end
  end

  def self.any?(**entities)
    entity_list = instance_method(:initialize).parameters.map(&:last).sort
    EventStore.instance.any? do |event|
      event.is_a?(self) &&
        entity_list.all? { |e| event.send(e).id == entities[e].id }
    end
  end

  def self.dispatch(**entities)
    new(**entities).dispatch
  end

  def dispatch
    @entities.each_value do |entity|
      entity.update_timestamp timestamp
    end
    raise unless EventStore.store self
  end

  def update(projection, transform)
    raise NotFoundError, 'All entity changes should update the timestamp, but this one does not' unless transform.key? :@timestamp
    transform.each do |key, value|
      projection.instance_variable_set key, value
    end
  end
end

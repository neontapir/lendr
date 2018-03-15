# frozen_string_literal: true

require 'securerandom'
require_relative 'entity.rb'

class Entity
  attr_reader :id, :timestamp

  def initialize
    @id = SecureRandom.uuid
    update_timestamp
  end

  def update_timestamp(new_time = Time.now)
    @timestamp = new_time
  end

  def ==(other)
    self.class == other.class &&
      id == other.id
  end

  alias_method :eql?, :==

  def hash
    id.hash
  end

  def self.find_by_attributes(time = Time.now, &entity_lookup)
    events = EventStore.instance.find_all do |event|
      begin
        time >= event.timestamp &&
          entity_lookup.call(event)
      rescue NoMethodError
        false
      end
    end.sort_by(&:timestamp)
    return nil if events.empty?

    project(events)
  end

  def self.find_by_id(id, time = Time.now, &event_id_lookup)
    events = EventStore.instance.find_all do |e|
      begin
        time >= e.timestamp &&
          id == event_id_lookup.call(e)
      rescue NoMethodError
        false
      end
    end.sort_by(&:timestamp)
    return nil if events.empty?

    project(events)
  end

  def self.project(events)
    projection = new
    events.each do |e|
      e.apply_to(projection)
    end
    projection
  end

  def to_s
    variables = instance_variables - [:@id, :@timestamp]
    properties = variables.map do |v|
      "#{v}: #{instance_variable_get(v.to_s)}"
    end.join(', ')
    "{ #{self.class}: #{properties} }"
  end
end

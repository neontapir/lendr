# frozen_string_literal: true

require 'securerandom'
require_relative 'entity.rb'

class Entity
  attr_reader :id, :timestamp

  def initialize
    @id = SecureRandom.uuid
    @timestamp = Time.now
  end

  def ==(other)
    self.class == other.class && id == other.id
  end

  alias_method :eql?, :==

  def hash
    id.hash
  end

  def self.find_by_attributes(&entity_lookup)
    events = EventStore.instance.find_all do |event|
      begin
        entity_lookup.call(event)
      rescue NoMethodError
        false
      end
    end.sort_by(&:timestamp)
    return nil if events.empty?

    projection = new
    events.each { |e| e.apply_to(projection) }
    projection
  end

  def self.find_by_id(id, &event_id_lookup)
    events = EventStore.instance.find_all do |e|
      begin
        id == event_id_lookup.call(e)
      rescue NoMethodError
        false
      end
    end.sort_by(&:timestamp)
    return nil if events.empty?

    projection = new
    events.each { |e| e.apply_to(projection) }
    projection
  end
end

# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class PatronCreatedEvent < Event
  attr_reader :patron

  def initialize(patron)
    super()
    @patron = patron
  end

  def self.raise(patron)
    event = new(patron)
    [patron, patron.books].each do |entity|
      entity.update_timestamp event.timestamp
    end
    EventStore.store event
  end

  def self.any?(patron:)
    EventStore.instance.any? do |e|
      e.is_a?(PatronCreatedEvent) &&
        e.patron.id == patron.id
    end
  end

  def apply_to(projection)
    projection.is_a?(Patron) &&
      update(projection,
             :@id => patron.id,
             :@timestamp => patron.timestamp,
             :@name => patron.name,
             :@books => patron.books)
  end
end

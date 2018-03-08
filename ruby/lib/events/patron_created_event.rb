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
    EventStore.instance << PatronCreatedEvent.new(patron)
  end

  def apply_to(projection)
    update(projection,
           :@id => patron.id,
           :@timestamp => patron.timestamp,
           :@name => patron.name,
           :@books => patron.books)
  end
end

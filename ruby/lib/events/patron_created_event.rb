# frozen_string_literal: true

require_relative 'event.rb'

class PatronCreatedEvent < Event
  def initialize(patron:)
    super
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

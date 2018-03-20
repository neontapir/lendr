# frozen_string_literal: true

require_relative 'event.rb'

class LibraryCreatedEvent < Event
  def initialize(library:)
    super
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@id => library.id,
             :@name => library.name,
             :@timestamp => library.timestamp)
  end
end

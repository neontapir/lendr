# frozen_string_literal: true

require_relative 'event.rb'
require_relative '../event_store.rb'

class LibraryCreatedEvent < Event
  attr_reader :library

  def initialize(library:)
    super()
    @library = library
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@id => library.id,
             :@name => library.name,
             :@timestamp => library.timestamp)
  end
end

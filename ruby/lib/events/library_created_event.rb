# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class LibraryCreatedEvent < Event
  attr_reader :library

  def initialize(library:)
    super()
    @library = library
  end

  # def self.raise(library:)
  #   super(library: library)
  # end

  def self.any?(library)
    EventStore.instance.any? do |e|
      e.is_a?(LibraryCreatedEvent) &&
        e.library.id == library.id
    end
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@id => library.id,
             :@name => library.name,
             :@timestamp => library.timestamp)
  end
end

require_relative '../entity.rb'
require_relative 'event_store.rb'

class LibraryCreatedEvent < Entity
  attr_reader :library

  def initialize(library)
    super()
    @library = library
  end

  def self.raise(library)
    EventStore.instance << LibraryCreatedEvent.new(library)
  end

  def apply_to(projection)
    projection.instance_variable_set(:@id, library.id)
    projection.instance_variable_set(:@timestamp, library.timestamp)
  end
end

require_relative '../entity.rb'
require_relative 'event_store.rb'

class LibraryCreatedEvent < Entity
  attr_reader :library_id

  def initialize(library)
    @library_id = library.id
    EventStore.instance << self
  end
end

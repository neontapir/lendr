require_relative '../entity.rb'
require_relative 'event_store.rb'

class BookAddedEvent < Entity
  attr_reader :library_id, :book_id

  def initialize(library:, book:)
    @book_id = book.id
    @library_id = library.id
    EventStore.instance << self
  end
end

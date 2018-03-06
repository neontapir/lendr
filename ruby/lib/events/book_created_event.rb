require_relative '../entity.rb'
require_relative 'event_store.rb'

class BookCreatedEvent < Entity
  attr_reader :book_id

  def initialize(book)
    @book_id = book.id
    EventStore.instance << self
  end
end

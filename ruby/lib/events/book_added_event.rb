require_relative '../entity.rb'
require_relative 'event_store.rb'

class BookAddedEvent < Entity
  attr_reader :library, :book

  def initialize(library:, book:)
    super()
    @book = book
    @library = library
  end

  def self.raise(library:, book:)
    EventStore.instance << BookAddedEvent.new(library: library, book: book)
  end

  def apply_to(projection)
    projection.instance_variable_set(:@timestamp, timestamp)
    projection.instance_variable_set(:@books, library.books)
  end
end

# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class BookCopyAddedEvent < Event
  attr_reader :library, :book

  def initialize(library:, book:)
    super()
    @book = book
    @library = library
  end

  def self.raise(library:, book:)
    EventStore.instance << BookCopyAddedEvent.new(library: library, book: book)
  end

  def apply_to(projection)
    update(projection,
           :@timestamp => timestamp,
           :@books => library.books)
  end
end

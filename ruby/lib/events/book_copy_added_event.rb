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

  def self.any?(library:, book:)
    EventStore.instance.any? do |e|
      e.is_a?(BookCopyAddedEvent) &&
        e.book.id == book.id &&
        e.library.id == library.id
    end
  end

  def apply_to(projection)
    update(projection,
           :@timestamp => timestamp,
           :@books => library.books)
  end
end

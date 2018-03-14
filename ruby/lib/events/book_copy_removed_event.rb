# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class BookCopyRemovedEvent < Event
  attr_reader :library, :book

  def initialize(library:, book:)
    super()
    @book = book
    @library = library
  end

  def self.raise(library:, book:)
    EventStore.instance << BookCopyRemovedEvent.new(library: library, book: book)
  end

  def self.any?(library:, book:)
    EventStore.instance.any? do |e|
      e.is_a?(BookCopyRemovedEvent) &&
        e.book.id == book.id &&
        e.library.id == library.id
    end
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@timestamp => timestamp,
             :@books => library.books)
  end
end

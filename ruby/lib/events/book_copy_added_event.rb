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
    event = new(library: library, book: book)
    [book, library, library.books].each do |entity|
      entity.update_timestamp event.timestamp
    end
    EventStore.store event
  end

  def self.any?(library:, book:)
    EventStore.instance.any? do |e|
      e.is_a?(BookCopyAddedEvent) &&
        e.book.id == book.id &&
        e.library.id == library.id
    end
  end

  def apply_to(projection)
    return unless projection.is_a?(Library)
    update(projection, :@timestamp => timestamp, :@books => library.books)
  end
end

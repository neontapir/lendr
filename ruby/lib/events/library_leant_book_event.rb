# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class LibraryLeantBookEvent < Event
  attr_reader :book, :library, :patron

  def initialize(book:, library:, patron:)
    super()
    @book = book
    @library = library
    @patron = patron
  end

  # # not strictly necessary
  # def self.raise(library:, book:, patron:)
  #   super(library: library, book: book, patron: patron)
  # end

  def self.any?(book:, library:, patron:)
    EventStore.instance.any? do |e|
      e.is_a?(LibraryLeantBookEvent) &&
        e.book.id == book.id &&
        e.patron.id == patron.id &&
        e.library.id == library.id
    end
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@timestamp => timestamp,
             :@books => library.books,
             :@patrons => library.patrons)
    projection.is_a?(Patron) &&
      update(projection,
             :@timestamp => timestamp,
             :@books => patron.books)
  end
end

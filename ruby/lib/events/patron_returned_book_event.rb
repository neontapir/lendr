# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class PatronReturnedBookEvent < Event
  attr_reader :book, :library, :patron

  def initialize(book:, library:, patron:)
    super()
    @book = book
    @library = library
    @patron = patron
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

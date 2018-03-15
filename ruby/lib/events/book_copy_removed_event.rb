# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class BookCopyRemovedEvent < Event
  attr_reader :book, :library

  def initialize(book:, library:)
    super()
    @book = book
    @library = library
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@timestamp => timestamp,
             :@books => library.books)
  end
end

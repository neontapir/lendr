# frozen_string_literal: true

require_relative 'event.rb'
require_relative '../event_store.rb'

class BookCopyAddedEvent < Event
  attr_reader :book, :library

  def initialize(book:, library:)
    super()
    @book = book
    @library = library
  end

  def apply_to(projection)
    return unless projection.is_a?(Library)
    update(projection,
           :@timestamp => timestamp,
           :@books => library.books)
  end
end

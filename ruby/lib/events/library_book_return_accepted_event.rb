# frozen_string_literal: true

require_relative 'event.rb'

class LibraryBookReturnAcceptedEvent < Event
  def initialize(book:, library:, patron:)
    super
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

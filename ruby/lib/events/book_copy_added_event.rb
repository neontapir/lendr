# frozen_string_literal: true

require_relative 'event.rb'

class BookCopyAddedEvent < Event
  def initialize(book:, library:)
    super
  end

  def apply_to(projection)
    return unless projection.is_a?(Library)
    update(projection,
           :@timestamp => timestamp,
           :@books => library.books)
  end
end

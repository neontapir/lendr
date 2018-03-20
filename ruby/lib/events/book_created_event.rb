# frozen_string_literal: true

require_relative 'event.rb'

class BookCreatedEvent < Event
  def initialize(book:)
    super
  end

  def apply_to(projection)
    projection.is_a?(Book) &&
      update(projection,
             :@id => book.id,
             :@timestamp => book.timestamp,
             :@title => book.title,
             :@author => book.author)
  end
end

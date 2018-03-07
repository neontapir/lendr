# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class BookCreatedEvent < Event
  attr_reader :book

  def initialize(book)
    super()
    @book = book
  end

  def self.raise(book)
    EventStore.instance << BookCreatedEvent.new(book)
  end

  def apply_to(projection)
    update(projection,
           :@id => book.id,
           :@timestamp => book.timestamp,
           :@name => book.name,
           :@author => book.author)
  end
end

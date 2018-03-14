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

  def self.any?(book)
    EventStore.instance.any? do |e|
      e.is_a?(BookCreatedEvent) &&
        e.book.id == book.id
    end
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

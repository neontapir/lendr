require_relative '../entity.rb'
require_relative 'event_store.rb'

class BookCreatedEvent < Entity
  attr_reader :book

  def initialize(book)
    super()
    @book = book
  end

  def self.raise(book)
    EventStore.instance << BookCreatedEvent.new(book)
  end

  def apply_to(projection)
    projection.instance_variable_set(:@id, book.id)
    projection.instance_variable_set(:@timestamp, book.timestamp)
    projection.instance_variable_set(:@name, book.name)
    projection.instance_variable_set(:@author, book.author)
  end
end

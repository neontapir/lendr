require_relative 'entity.rb'
require_relative 'events/book_created_event.rb'

class Book < Entity
  attr_reader :name, :author

  def initialize(name:, author:)
    super()
    @name = name
    @author = author
    BookCreatedEvent.new self
  end
end

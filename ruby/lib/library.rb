require_relative 'books.rb'
require_relative 'entity.rb'
require_relative 'events/book_added_event.rb'
require_relative 'events/library_created_event.rb'

class Library < Entity
  attr_reader :books

  def initialize
    super
    @books = Books.new
    LibraryCreatedEvent.new self
  end

  def add(book)
    @books << book
    BookAddedEvent.new(library: self, book: book)
  end
end

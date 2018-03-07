require_relative 'books.rb'
require_relative 'entity.rb'
require_relative 'events/book_added_event.rb'
require_relative 'events/library_created_event.rb'

class Library < Entity
  attr_reader :books

  def self.create
    library = Library.new
    LibraryCreatedEvent.raise library
    library
  end

  def self.get(id)
    get_by_id(id) { |event| event.library.id }
  end

  def add(book)
    @books << book
    BookAddedEvent.raise(library: self, book: book)
  end

  def to_s
    "Library { id: '#{id}' }"
  end

  private

  def initialize()
    super
    @books = Books.new
  end
end

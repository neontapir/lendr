# frozen_string_literal: true

require_relative 'books.rb'
require_relative 'entity.rb'
require_relative 'events/book_added_event.rb'
require_relative 'events/library_created_event.rb'

class Library < Entity
  attr_reader :books, :name

  def self.create(name)
    library = find_by_attributes { |event| name == event.library.name }
    unless library
      library = Library.new(name: name)
      LibraryCreatedEvent.raise library
    end
    library
  end

  def self.get(id)
    find_by_id(id) { |event| event.library.id }
  end

  def add(book)
    @books[book] = @books[book] + 1
    BookAddedEvent.raise(library: self, book: book)
  end

  def to_s
    "Library { id: '#{id}', name: '#{name}' }"
  end

  private

  def initialize(name: nil)
    super()
    @name = name
    @books = Books.new
  end
end

# frozen_string_literal: true

require_relative 'books.rb'
require_relative 'book_disposition.rb'
require_relative 'entity.rb'
require_relative 'patrons.rb'
require_relative 'events/book_added_event.rb'
require_relative 'events/book_removed_event.rb'
require_relative 'events/library_created_event.rb'
require_relative 'events/patron_registered_event.rb'

class Library < Entity
  attr_reader :books, :patrons, :name

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
    @books[book] = @books[book].add_owned(1).add_in_circulation(1)
    BookAddedEvent.raise(library: self, book: book)
  end

  def remove(book)
    return unless @books.key? book
    @books[book] = @books[book].subtract_owned(1).subtract_in_circulation(1)
    @books.delete book if @books[book].owned < 1
    BookRemovedEvent.raise(library: self, book: book)
  end

  def register_patron(patron)
    @patrons[patron] = @patrons[patron].change_standing(:good)
    PatronRegisteredEvent.raise(library: self, patron: patron)
  end

  def to_s
    "Library { id: '#{id}', name: '#{name}' }"
  end

  private

  def initialize(name: nil)
    super()
    @name = name
    @books = Books.new
    @patrons = Patrons.new
  end
end

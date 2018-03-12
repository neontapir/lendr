# frozen_string_literal: true

require_relative 'person.rb'
require_relative 'events/patron_created_event.rb'
require_relative 'events/patron_borrowed_book_event.rb'

class Patron < Person
  attr_reader :books

  def self.create(name)
    patron = find_by_attributes { |event| name == event.patron.name }
    unless patron
      patron = Patron.new(name)
      PatronCreatedEvent.raise patron
    end
    patron
  end

  def self.get(id)
    find_by_id(id) { |event| event.patron.id }
  end

  def borrow(book:, library:)
    @books[book] = @books[book].add_owned(1)
    PatronBorrowedBookEvent.raise(library: library, book: book, patron: self)
  end

  def to_s
    "Patron { id: '#{id}' }"
  end

  private

  def initialize(name = nil)
    super(name)
    @books = Books.new
  end
end

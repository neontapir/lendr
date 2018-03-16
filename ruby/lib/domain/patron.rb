# frozen_string_literal: true

require_relative '../collections/books.rb'
require_relative 'person.rb'
require_relative '../events/patron_created_event.rb'
require_relative '../events/patron_borrowed_book_event.rb'
require_relative '../events/patron_returned_book_event.rb'

class Patron < Person
  attr_reader :books

  def self.create(name)
    patron = find_by_attributes { |event| name == event.patron.name }
    unless patron
      patron = Patron.new(name)
      PatronCreatedEvent.dispatch patron: patron
    end
    patron
  end

  def borrow(book:, library:)
    raise ArgumentError unless book.is_a? Book
    raise ArgumentError unless library.is_a? Library
    return unless patron_of?(library)
    @books.add book unless borrowing?(book)
    @books.update(book) { |b| b.add_borrowed(1) }
    PatronBorrowedBookEvent.dispatch(library: library, book: book, patron: self)
  end

  def return(book:, library:)
    raise ArgumentError unless book.is_a? Book
    raise ArgumentError unless library.is_a? Library
    return unless patron_of?(library)
    @books.update(book) { |b| b.subtract_borrowed(1) }
    @books.delete book unless @books[book].borrowed.positive?
    PatronReturnedBookEvent.dispatch(library: library, book: book, patron: self)
    library.return(book: book, patron: self)
  end

  def borrowing?(book)
    @books.key? book
  end

  def patron_of?(library)
    library.patron?(self)
  end

  private

  def initialize(name = nil)
    super(name)
    @books = Books.create_for_patron
  end
end

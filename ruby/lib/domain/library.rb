# frozen_string_literal: true

require_relative '../collections/books.rb'
require_relative 'entity.rb'
require_relative '../collections/patrons.rb'
require_relative '../events/book_copy_added_event.rb'
require_relative '../events/book_copy_removed_event.rb'
require_relative '../events/library_leant_book_event.rb'
require_relative '../events/library_created_event.rb'
require_relative '../events/library_book_return_accepted_event.rb'
require_relative '../events/patron_registered_event.rb'
require_relative '../events/patron_standing_changed_event.rb'

class Library < Entity
  attr_reader :books, :patrons, :name

  def self.create(name)
    library = find_by_attributes { |event| name == event.library.name }
    unless library
      library = Library.new(name: name)
      LibraryCreatedEvent.dispatch library: library
    end
    library
  end

  def add(book)
    raise ArgumentError, "#{book} is not a book" unless book.is_a? Book
    @books.add(book) unless owns?(book)
    @books.update(book) { |b| b.add_owned(1).add_in_circulation(1) }
    BookCopyAddedEvent.dispatch(library: self, book: book)
  end

  def lend(book:, patron:)
    return unless owns?(book) &&
                  in_circulation?(book) &&
                  patron?(patron) &&
                  may_borrow?(patron)
    @books.update(book) { |b| b.subtract_in_circulation(1) }
    LibraryLeantBookEvent.dispatch(library: self, book: book, patron: patron)
    patron.borrow(book: book, library: self)
  end

  def return(book:, patron:)
    @books.update(book) { |b| b.add_in_circulation(1) }
    LibraryBookReturnAcceptedEvent.dispatch(library: self, book: book, patron: patron)
  end

  def remove(book)
    return unless owns?(book)
    @books.update(book) { |b| b.subtract_owned(1).subtract_in_circulation(1) }
    @books.delete book unless owns?(book)
    BookCopyRemovedEvent.dispatch(library: self, book: book)
  end

  def register_patron(patron)
    raise ArgumentError, "#{patron} is not a patron" unless patron.is_a? Patron
    @patrons.add(patron)
    PatronRegisteredEvent.dispatch(library: self, patron: patron)
    allow_borrowing(patron)
  end

  def allow_borrowing(patron)
    @patrons.update(patron) { |_| PatronDisposition.good }
    PatronStandingChangedEvent.dispatch(library: self, patron: patron)
  end

  def revoke_borrowing(patron)
    @patrons.update(patron) { |_| PatronDisposition.poor }
    PatronStandingChangedEvent.dispatch(library: self, patron: patron)
  end

  def owns?(book)
    @books.key?(book) && @books[book].owned.positive?
  end

  def in_circulation?(book)
    owns?(book) && @books[book].in_circulation.positive?
  end

  def patron?(patron)
    @patrons.key?(patron)
  end

  def may_borrow?(patron)
    @patrons[patron] == PatronDisposition.good
  end

  private

  def initialize(name: nil, books: Books.create_library, patrons: Patrons.create)
    super()
    @name = name
    @books = books
    @patrons = patrons
  end
end

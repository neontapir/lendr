# frozen_string_literal: true

require_relative 'books.rb'
require_relative 'entity.rb'
require_relative 'patrons.rb'
require_relative 'events/book_copy_added_event.rb'
require_relative 'events/book_copy_removed_event.rb'
require_relative 'events/library_leant_book_event.rb'
require_relative 'events/library_created_event.rb'
require_relative 'events/library_book_return_accepted_event.rb'
require_relative 'events/patron_registered_event.rb'
require_relative 'events/patron_standing_changed_event.rb'

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
    @books.add(book) unless @books.key? book
    @books.update(book) { |b| b.add_owned(1).add_in_circulation(1) }
    BookCopyAddedEvent.raise(library: self, book: book)
  end

  def lend(book:, patron:)
    return unless owns?(book) &&
                  in_circulation?(book) &&
                  patron?(patron) &&
                  may_borrow?(patron)
    @books.update(book) { |b| b.subtract_in_circulation(1) }
    LibraryLeantBookEvent.raise(library: self, book: book, patron: patron)
    patron.borrow(book: book, library: self)
  end

  def return(book:, patron:)
    @books.update(book) { |b| b.add_in_circulation(1) }
    LibraryBookReturnAcceptedEvent.raise(library: self, book: book, patron: patron)
  end

  def remove(book)
    return unless owns?(book)
    @books.update(book) { |b| b.subtract_owned(1).subtract_in_circulation(1) }
    @books.delete book if @books[book].owned < 1
    BookCopyRemovedEvent.raise(library: self, book: book)
  end

  def register_patron(patron)
    @patrons.add(patron)
    PatronRegisteredEvent.raise(library: self, patron: patron)
    allow_borrowing(patron)
  end

  def allow_borrowing(patron)
    @patrons.update(patron) { |_| PatronDisposition.good }
    PatronStandingChangedEvent.raise(library: self, patron: patron)
  end

  def revoke_borrowing(patron)
    @patrons.update(patron) { |_| PatronDisposition.poor }
    PatronStandingChangedEvent.raise(library: self, patron: patron)
  end

  def owns?(book)
    @books.key?(book)
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

  def to_s
    "Library { id: '#{id}', name: '#{name}' }"
  end

  private

  def initialize(name: nil)
    super()
    @name = name
    @books = Books.create_library
    @patrons = Patrons.create
  end
end

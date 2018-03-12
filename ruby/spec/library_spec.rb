# frozen_string_literal: true
# encoding: utf-8

require 'timecop'
require 'uuid'
require_relative '../lib/book.rb'
require_relative '../lib/library.rb'
require_relative '../lib/patron.rb'

RSpec.describe 'the library' do
  let(:subject) { Library.create 'the library spec' }
  
  context 'a new library' do
    
    it 'should have a valid UUID as an identifier' do
      expect(UUID.validate(subject.id)).to be_truthy
    end

    it 'should have an empty books collection' do
      expect(subject.books).to be_empty
    end

    it 'should have an empty patrons collection' do
      expect(subject.patrons).to be_empty
    end

    it 'should have a current timestamp' do
      instant = Time.local(2008, 9, 1, 12, 0, 0) # arbitrary
      Timecop.freeze instant
      expect(Library.create('timestamp test library').timestamp).to eq(instant)
      Timecop.return
    end

    it 'should raise a creation event' do
      expect(subject).not_to be_nil # force let to be evaluated
      subject_created = EventStore.instance.any? do |e|
        e.is_a?(LibraryCreatedEvent) && e.library.id == subject.id
      end
      expect(subject_created).to be_truthy
    end
  end

  context 'adding a book to the library' do
    it 'should raise a book copy added event' do
      book = Book.create(title: 'The Little Prince',
                         author: 'Antoine de Saint-Exupéry')
      subject.add book

      book_added = EventStore.instance.any? do |e|
        e.is_a?(BookCopyAddedEvent) &&
          e.book.id == book.id &&
          e.library.id == subject.id
      end
      expect(book_added).to be_truthy
    end

    it 'a new book results in 1 copy in the library' do
      library = Library.create 'single copy library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, LibraryBookDisposition.new(owned: 1, in_circulation: 1)])
    end

    it 'an existing book increments the quantity of that book by 1' do
      library = Library.create 'multiple copies library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, LibraryBookDisposition.new(owned: 2, in_circulation: 2)])
    end

    it 'a new book can be added to a library that already has a different book' do
      library = Library.create 'multiple books library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to include(little_prince)
      expect(library.books[little_prince]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)

      dune = Book.create(title: 'Dune',
                         author: 'Frank Herbert')
      library.add dune

      expect(library.books[little_prince]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)
      expect(library.books[dune]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)
    end

    it 'a new book can be added with multiple books in the library' do
      library = Library.create 'multiple books addition library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince

      dune = Book.create(title: 'Dune',
                         author: 'Frank Herbert')
      library.add dune
      library.add dune

      expect(library.books[little_prince]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)
      expect(library.books[dune]).to eq LibraryBookDisposition.new(owned: 2, in_circulation: 2)
    end
  end

  context 'removing a book' do
    it 'should raise a book copy removed event' do
      subject = Library.create 'the removing books library'
      book = Book.create(title: 'The Little Prince',
                         author: 'Antoine de Saint-Exupéry')
      subject.add book
      subject.remove book

      book_removed = EventStore.instance.any? do |e|
        e.is_a?(BookCopyRemovedEvent) &&
          e.book.id == book.id &&
          e.library.id == subject.id
      end
      expect(book_removed).to be_truthy
    end

    it 'means 1 less copy owned by the library' do
      subject = Library.create 'removing 1984 library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')
      subject.add nineteen_eighty_four
      subject.add nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, LibraryBookDisposition.new(owned: 2, in_circulation: 2)])

      subject.remove nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, LibraryBookDisposition.new(owned: 1, in_circulation: 1)])
    end

    it 'removes it from the library\'s collection if it is the last book owned' do
      subject = Library.create 'removing all 1984 copies library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')
      subject.add nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, LibraryBookDisposition.new(owned: 1, in_circulation: 1)])

      subject.remove nineteen_eighty_four
      expect(subject.books).to be_empty
    end

    it 'removing a non-existant book is a no-op' do
      subject = Library.create 'removing book from empty library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')

      subject.remove nineteen_eighty_four
      expect(subject.books).to be_empty

      book_removed = EventStore.instance.any? do |e|
        e.is_a?(BookCopyRemovedEvent) &&
          e.book.id == nineteen_eighty_four.id &&
          e.library.id == subject.id
      end
      expect(book_removed).to be_falsey
    end
  end

  context 'registering a new patron' do
    it 'should raise a patron registered event' do
      patron = Patron.create 'John Doe'
      subject.register_patron patron

      patron_registered = EventStore.instance.any? do |e|
        e.is_a?(PatronRegisteredEvent) &&
          e.patron.id == patron.id &&
          e.library.id == subject.id
      end
      expect(patron_registered).to be_truthy
    end

    it 'puts the person in good standing' do
      patron = Patron.create 'Jane Doe'
      subject.register_patron patron

      expect(subject.patrons[patron].standing).to eq :good
    end

    it 'should not affect the standing of the patron at a different library' do
      library1 = Library.create 'First library for registering patrons'
      library2 = Library.create 'Second library for registering patrons'
      patron = Patron.create 'Jane Doe'
      library1.register_patron patron

      expect(library1.patrons[patron].standing).to eq :good
      expect(library2.patrons[patron].standing).to eq :none
    end
  end

  context 'lending an available book' do
    library = Library.create 'happy path lending library'
    pierre = Patron.create 'Pierre "Happy Path" Toulemonde'
    left_hand_darkness = Book.create(title: 'The Left Hand of Darkness', author: 'Ursula K. LeGuin')
    library.add left_hand_darkness
    library_books_before = Marshal.load(Marshal.dump(library.books))
    patron_books_before = Marshal.load(Marshal.dump(pierre.books))
    library.register_patron pierre
    library.lend(book: left_hand_darkness, patron: pierre)

    it 'the preconditions are correct' do
      expect(library_books_before[left_hand_darkness].owned).to eq 1
      expect(library_books_before[left_hand_darkness].in_circulation).to eq 1
      expect(patron_books_before[left_hand_darkness].borrowed).to eq 0
    end

    it 'raise a book leant event' do
      book_leant = EventStore.instance.any? do |e|
        e.is_a?(LibraryLeantBookEvent) &&
          e.book.id == left_hand_darkness.id &&
          e.patron.id == pierre.id &&
          e.library.id == library.id
      end
      expect(book_leant).to be_truthy
    end

    it 'raise a patron borrowed event' do
      book_borrowed = EventStore.instance.any? do |e|
        e.is_a?(PatronBorrowedBookEvent) &&
          e.book.id == left_hand_darkness.id &&
          e.patron.id == pierre.id &&
          e.library.id == library.id
      end
      expect(book_borrowed).to be_truthy
    end

    it 'removes the book from circulation' do
      expect(library.books[left_hand_darkness].owned).to eq 1
      expect(library.books[left_hand_darkness].in_circulation).to eq 0
    end

    it 'becomes borrowed by the patron' do
      expect(pierre.books[left_hand_darkness].borrowed).to eq 1
    end
  end

  context 'will not lend an unavailable book' do
    it 'is a pending example'
  end

  context 'will not lend a book to a patron in bad standing' do
    it 'is a pending example'
  end
end

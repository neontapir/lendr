# frozen_string_literal: true
# encoding: utf-8

require 'timecop'
require 'uuid'
require_relative '../lib/book.rb'
require_relative '../lib/library.rb'

RSpec.describe 'the library' do
  let(:subject) { Library.create 'the library spec' }

  it 'should have a valid ID' do
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

  context 'when adding books to the library' do
    it 'adding a book should raise a book added event' do
      book = Book.create(title: 'The Little Prince',
                         author: 'Antoine de Saint-Exupéry')
      subject.add book

      book_added = EventStore.instance.any? do |e|
        e.is_a?(BookAddedEvent) &&
          e.book.id == book.id &&
          e.library.id == subject.id
      end
      expect(book_added).to be_truthy
    end

    it 'adding a new book makes 1 copy in the library' do
      library = Library.create 'single copy library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, BookDisposition.new(owned: 1, in_circulation: 1)])
    end

    it 'adding the same book increments the quantity of that book by 1' do
      library = Library.create 'multiple copies library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, BookDisposition.new(owned: 2, in_circulation: 2)])
    end

    it 'adding a new book works with an existing library that already has a different book' do
      library = Library.create 'multiple books library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to include(little_prince)
      expect(library.books[little_prince]).to eq BookDisposition.new(owned: 1, in_circulation: 1)

      dune = Book.create(title: 'Dune',
                         author: 'Frank Herbert')
      library.add dune

      expect(library.books[little_prince]).to eq BookDisposition.new(owned: 1, in_circulation: 1)
      expect(library.books[dune]).to eq BookDisposition.new(owned: 1, in_circulation: 1)
    end

    it 'adds a new book correctly with multiple books in the library' do
      library = Library.create 'multiple books addition library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince

      dune = Book.create(title: 'Dune',
                         author: 'Frank Herbert')
      library.add dune
      library.add dune

      expect(library.books[little_prince]).to eq BookDisposition.new(owned: 1, in_circulation: 1)
      expect(library.books[dune]).to eq BookDisposition.new(owned: 2, in_circulation: 2)
    end
  end

  context 'when removing books from the library' do
    it 'removing a book should raise a book removed event' do
      subject = Library.create 'the removing books library'
      book = Book.create(title: 'The Little Prince',
                         author: 'Antoine de Saint-Exupéry')
      subject.add book
      subject.remove book

      book_removed = EventStore.instance.any? do |e|
        e.is_a?(BookRemovedEvent) &&
          e.book.id == book.id &&
          e.library.id == subject.id
      end
      expect(book_removed).to be_truthy
    end

    it 'removing a book means 1 less copy in the library' do
      subject = Library.create 'removing 1984 library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')
      subject.add nineteen_eighty_four
      subject.add nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, BookDisposition.new(owned: 2, in_circulation: 2)])

      subject.remove nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, BookDisposition.new(owned: 1, in_circulation: 1)])
    end

    it 'removing the last copy of a book also removes it from the collection' do
      subject = Library.create 'removing all 1984 copies library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')
      subject.add nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, BookDisposition.new(owned: 1, in_circulation: 1)])

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
        e.is_a?(BookRemovedEvent) &&
          e.book.id == nineteen_eighty_four.id &&
          e.library.id == subject.id
      end
      expect(book_removed).to be_falsey
    end
  end

  context 'when registering patrons for the library' do
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

    it 'new patrons are in good standing' do
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
end

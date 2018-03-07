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
      book = Book.create(name: 'The Little Prince',
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
      little_prince = Book.create(name: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, 1])
    end

    it 'adding the same book increments the quantity of that book by 1' do
      library = Library.create 'multiple copies library'
      little_prince = Book.create(name: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, 2])
    end

    it 'adding a new book works with an existing library that already has a different book' do
      library = Library.create 'multiple books library'
      little_prince = Book.create(name: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to include(little_prince)
      expect(library.books[little_prince]).to be 1

      dune = Book.create(name: 'Dune',
                         author: 'Frank Herbert')
      library.add dune

      expect(library.books[little_prince]).to be 1
      expect(library.books[dune]).to be 1
    end

    it 'adds a new book correctly with multiple books in the library' do
      library = Library.create 'multiple books addition library'
      little_prince = Book.create(name: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince

      dune = Book.create(name: 'Dune',
                         author: 'Frank Herbert')
      library.add dune
      library.add dune

      expect(library.books[little_prince]).to be 1
      expect(library.books[dune]).to be 2
    end
  end
end

# frozen_string_literal: true
# encoding: utf-8

require_relative '../lib/author.rb'
require_relative '../lib/book.rb'
require_relative '../lib/library.rb'
require_relative '../lib/library_book_disposition.rb'
require_relative '../lib/patron.rb'

RSpec.describe 'the event store' do
  context 'getting an author by id' do
    let(:author) do
      Author.create(name: 'Antoine de Saint-Exupéry')
    end

    it 'retrieves the book if it exists' do
      subject = Author.get(author.id)
      expect(subject.to_s).to eq(author.to_s)
      expect(subject.id).to eq(author.id)
      expect(subject.timestamp).to eq(author.timestamp)
      expect(subject.name).to eq(author.name)
    end

    it 'returns nil if the book does not exist' do
      expect(Author.get('xyzzy')).to be_nil
    end
  end

  context 'getting a book by id' do
    let(:book) do
      Book.create(title: 'The Little Prince', 
                  author: 'Antoine de Saint-Exupéry')
    end

    it 'retrieves the book if it exists' do
      subject = Book.get(book.id)
      expect(subject.to_s).to eq(book.to_s)
      expect(subject.id).to eq(book.id)
      expect(subject.timestamp).to eq(book.timestamp)
      expect(subject.title).to eq(book.title)
      expect(subject.author).to eq(book.author)
    end

    it 'returns nil if the book does not exist' do
      expect(Book.get('xyzzy')).to be_nil
    end
  end

  context 'getting a library by id' do
    let(:library) { Library.create 'get by id test library' }

    it 'retrieves the library if it exists' do
      _ = Library.create 'make sure multiple libraries in the store library'
      subject = Library.get(library.id)
      expect(subject.to_s).to eq(library.to_s)
      expect(subject.id).to eq(library.id)
      expect(subject.timestamp).to eq(library.timestamp)
      expect(subject.books).to be_empty
    end

    it 'returns nil if the library does not exist' do
      expect(Library.get('xyzzy')).to be_nil
    end

    it 'retrieves the updated library after a book is added' do
      old_timestamp = library.timestamp
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince

      subject = Library.get(library.id)
      expect(subject.timestamp).to be > old_timestamp
      expect(subject.books).to contain_exactly([little_prince, LibraryBookDisposition.new(owned: 1, in_circulation: 1)])
    end
  end

  context 'getting a patron by id' do
    it 'gets the patron if it exists' do
      patron = Patron.create('John Doe')
      subject = Patron.get(patron.id)

      expect(subject.to_s).to eq(patron.to_s)
      expect(subject.id).to eq(patron.id)
      expect(subject.timestamp).to eq(patron.timestamp)
      expect(subject.name).to eq(patron.name)
      expect(subject.books).to eq(patron.books)
    end

    it 'returns nil if the patron does not exist' do
      expect(Patron.get('xyzzy')).to be_nil
    end
  end

  context 'events that impact multiple domain objects' do
    library = Library.create 'event store testing lending library'
    jan = Patron.create 'Jan Alleman'
    name_of_the_wind = Book.create(title: 'The Name of the Wind', author: 'Patrick Rothfuss')
    library.add name_of_the_wind
    library.register_patron jan
    library.lend(book: name_of_the_wind, patron: jan)

    it 'captures updates to the library' do
      stored_library = Library.get(library.id)
      expect(stored_library.books).to eq library.books
      expect(stored_library.patrons).to eq library.patrons
      expect(stored_library).to eq library
    end

    it 'captures updates to the patron' do
      stored_patron = Patron.get(jan.id)
      expect(stored_patron).to eq jan
    end

    it 'captures updates to the book' do
      stored_book = Book.get(name_of_the_wind.id)
      expect(stored_book).to eq name_of_the_wind
    end

    it 'captures updates to the author' do
      stored_author = Author.get(name_of_the_wind.author.id)
      expect(stored_author.name).to eq 'Patrick Rothfuss'
    end
  end
end

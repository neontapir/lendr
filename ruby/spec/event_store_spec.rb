# frozen_string_literal: true
# encoding: utf-8

require_relative '../lib/library.rb'

RSpec.describe 'the event store' do
  context 'getting a book by id' do
    let(:book) do
      Book.create(title: 'The Little Prince', 
                  author: 'Antoine de Saint-Exupéry')
    end

    it 'gets the book if it exists' do
      subject = Book.get(book.id)
      expect(subject.to_s).to eq(book.to_s)
      expect(subject.id).to eq(book.id)
      expect(subject.timestamp).to eq(book.timestamp)
      expect(subject.title).to eq(book.title)
      expect(subject.author).to eq(book.author)
    end
  end

  context 'getting a library by id' do
    let(:library) { Library.create 'get by id test library' }

    it 'gets the library if it exists' do
      _ = Library.create 'make sure multiple libraries in the store library'
      subject = Library.get(library.id)
      expect(subject.to_s).to eq(library.to_s)
      expect(subject.id).to eq(library.id)
      expect(subject.timestamp).to eq(library.timestamp)
      expect(subject.books).to be_empty
    end

    it 'gets the updated library after a book is added' do
      old_timestamp = library.timestamp
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince

      subject = Library.get(library.id)
      expect(subject.timestamp).to be > old_timestamp
      expect(subject.books).to contain_exactly([little_prince, 1])
    end

    it 'get returns nil if the entity does not exist' do
      subject = Library.get('xyzzy') # invalid key
      expect(subject).to be_nil
    end
  end

  context 'adding a book to a library' do
    it 'should raise a creation event' do
      library = Library.create 'creation event test library'
      event = EventStore.instance.find do |e|
        e.is_a?(LibraryCreatedEvent) && e.library.id == library.id
      end
      expect(event).not_to be_nil
    end
  end
end

require 'timecop'
require 'uuid'
require_relative '../lib/book.rb'
require_relative '../lib/library.rb'

RSpec.describe 'the library' do
  let(:subject) { Library.new }

  it 'should have a valid ID' do
    expect(UUID.validate(subject.id)).to be_truthy
  end

  it 'should have an empty books collection' do
    expect(subject.books).to be_empty
  end

  it 'should have a valid timestamp' do
    instant = Time.local(2008, 9, 1, 12, 0, 0) # arbitrary
    Timecop.freeze instant
    expect(Library.new.timestamp).to eq(instant)
    Timecop.return
  end

  it 'should raise a creation event' do
    subject_created = EventStore.instance.any? do |e|
      e.is_a?(LibraryCreatedEvent) && e.library_id == subject.id
    end
    expect(subject_created).to be_truthy
  end

  context 'when working with a book' do
    book = Book.new(name: 'The Little Prince',
      author: 'Antoine de Saint-Exupéry')

    it 'adding a book should raise a book added event' do
      subject.add book

      book_added = EventStore.instance.any? do |e|
        e.is_a?(BookAddedEvent) &&
        e.book_id == book.id &&
        e.library_id == subject.id
      end
      expect(book_added).to be_truthy
    end
  end
end

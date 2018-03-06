require 'uuid'
require_relative '../lib/book.rb'

RSpec.describe 'the book' do
  name = 'The Little Prince'
  author = 'Antoine de Saint-Exupéry'
  let(:subject) { Book.new(name: name, author: author) }

  context 'when creating a new book' do
    it 'should have a valid ID' do
      expect(UUID.validate(subject.id)).to be_truthy
    end

    it 'should have a name and author' do
      expect(subject.name).to eq(name)
      expect(subject.author).to eq(author)
    end

    it 'should raise a creation event' do
      subject_created = EventStore.instance.any? do |e|
        e.is_a?(BookCreatedEvent) && e.book_id == subject.id
      end
      expect(subject_created).to be_truthy
    end
  end
end

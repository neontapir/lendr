# frozen_string_literal: true
# encoding: utf-8

require 'uuid'
require_relative '../lib/book.rb'

RSpec.describe 'the book' do
  title = 'The Little Prince'
  author = 'Antoine de Saint-Exupéry'
  let(:subject) { Book.create(title: title, author: author) }

  context 'a new book' do
    it 'should have a valid UUID as an identifier' do
      expect(UUID.validate(subject.id)).to be_truthy
    end

    it 'should have a title and author' do
      expect(subject.title).to eq(title)
      expect(subject.author.name).to eq(author)
    end

    it 'should raise a book creation event' do
      expect(subject).not_to be_nil # force let eval
      expect(BookCreatedEvent.any?(book: subject)).to be_truthy
    end
  end

  context 'trying to create an existing book' do
    title = 'The Martian'
    author = 'Andy Weir'
    let(:first) { Book.create(title: title, author: author) }
    let(:duplicate) { Book.create(title: title, author: author) }

    it 'should return the first one instead' do
      expect(first).to eq(duplicate)
    end

    it 'should not raise a book created event' do
      book_created_events = EventStore.instance.find_all do |e|
        e.is_a?(BookCreatedEvent) && e.book == first
      end
      expect(book_created_events.size).to eq 1
    end
  end
end

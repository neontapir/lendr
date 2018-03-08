# frozen_string_literal: true
# encoding: utf-8

require 'uuid'
require_relative '../lib/book.rb'

RSpec.describe 'the book' do
  name = 'The Little Prince'
  author = 'Antoine de Saint-Exupéry'
  let(:subject) { Book.create(name: name, author: author) }

  context 'when creating a new book' do
    it 'should have a valid ID' do
      expect(UUID.validate(subject.id)).to be_truthy
    end

    it 'should have a name and author' do
      expect(subject.name).to eq(name)
      expect(subject.author.name).to eq(author)
    end

    it 'should raise a creation event' do
      expect(subject).not_to be_nil # force let eval
      subject_created = EventStore.instance.any? do |e|
        e.is_a?(BookCreatedEvent) && e.book.to_s == subject.to_s
      end
      expect(subject_created).to be_truthy
    end
  end

  context 'when trying to create an existing book' do
    name = 'The Martian'
    author = 'Andy Weir'
    let(:first) { Book.create(name: name, author: author) }
    let(:duplicate) { Book.create(name: name, author: author) }

    it 'should return the first one instead' do
      expect(first).to eq(duplicate)
    end

    it 'should only trigger one book created event' do
      book_created_events = EventStore.instance.find_all do |e|
        e.is_a?(BookCreatedEvent) && e.book == first
      end
      expect(book_created_events.size).to eq 1
    end
  end
end

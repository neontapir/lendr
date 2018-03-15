# frozen_string_literal: true
# encoding: utf-8

require 'uuid'
require_relative '../lib/author.rb'

RSpec.describe 'the author' do
  name = 'Frank Herbert'
  let(:subject) { Author.create(name) }

  context 'a new author' do
    it 'should have a valid UUID as an identifier' do
      expect(subject).not_to be_nil # force let eval
      expect(UUID.validate(subject.id)).to be_truthy
    end

    it 'should have a name' do
      expect(subject).not_to be_nil # force let eval
      expect(subject.name).to eq(name)
    end

    it 'should raise a creation event' do
      expect(subject).not_to be_nil # force let eval
      expect(AuthorCreatedEvent.any?(author: subject)).to be_truthy
    end
  end

  context 'trying to create an existing author' do
    name = 'Andy Weir'
    let(:first) { Author.create(name) }
    let(:duplicate) { Author.create(name) }

    it 'should return the first one instead' do
      expect(first).to eq(duplicate)
    end

    it 'should not raise an author created event' do
      author_created_events = EventStore.instance.find_all do |e|
        e.is_a?(AuthorCreatedEvent) && e.author == first
      end
      expect(author_created_events.size).to eq 1
    end
  end
end

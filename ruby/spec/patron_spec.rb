# frozen_string_literal: true
# encoding: utf-8

require 'uuid'
require_relative '../lib/patron.rb'

RSpec.describe 'the patron' do
  name = 'John Doe'
  let(:subject) { Patron.create(name) }

  context 'when creating a new patron' do
    it 'should have a valid ID' do
      expect(subject).not_to be_nil # force let eval
      expect(UUID.validate(subject.id)).to be_truthy
    end

    it 'should have a name' do
      expect(subject).not_to be_nil # force let eval
      expect(subject.name).to eq(name)
    end

    it 'should have a empty collection of books' do
      expect(subject).not_to be_nil # force let eval
      expect(subject.books).to be_empty
    end

    it 'should raise a creation event' do
      expect(subject).not_to be_nil # force let eval
      subject_created = EventStore.instance.any? do |e|
        e.is_a?(PatronCreatedEvent) && e.patron.name == subject.name
      end
      expect(subject_created).to be_truthy
    end
  end

  context 'when trying to create an existing patron' do
    name = 'Jane Doe'
    let(:first) { Patron.create(name) }
    let(:duplicate) { Patron.create(name) }

    it 'should return the first one instead' do
      expect(first).to eq(duplicate)
    end

    it 'should only trigger one patron created event' do
      patron_created_events = EventStore.instance.find_all do |e|
        e.is_a?(PatronCreatedEvent) && e.patron == first
      end
      expect(patron_created_events.size).to eq 1
    end
  end
end

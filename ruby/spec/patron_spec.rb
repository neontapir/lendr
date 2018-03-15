# frozen_string_literal: true
# encoding: utf-8

require 'uuid'
require_relative '../lib/book.rb'
require_relative '../lib/library.rb'
require_relative '../lib/patron.rb'

RSpec.describe 'the patron' do
  name = 'John Doe'
  let(:subject) { Patron.create(name) }

  context 'a newly created patron' do
    it 'should have a valid UUID as an identifier' do
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

  context 'trying to create an already-existing patron' do
    name = 'Jane Doe'
    let(:first) { Patron.create(name) }
    let(:duplicate) { Patron.create(name) }

    it 'should return the first one instead' do
      expect(first).to eq(duplicate)
    end

    it 'should not raise a patron created event' do
      patron_created_events = EventStore.instance.find_all do |e|
        e.is_a?(PatronCreatedEvent) && e.patron == first
      end
      expect(patron_created_events.size).to eq 1
    end
  end

  context 'returning a borrowed book' do
    before :all do
      @library = Library.create 'happy path returning library'
      @fulan = Patron.create 'Fulan al-Fulani'
      @library.register_patron @fulan
      @utopia = Book.create(title: 'Utopia', author: 'Ahmed Tawfiq')
      @library.add @utopia
      @library.lend(book: @utopia, patron: @fulan)
      @library_books_before = Marshal.load(Marshal.dump(@library.books))
      @patron_books_before = Marshal.load(Marshal.dump(@fulan.books))
      @fulan.return(book: @utopia, library: @library)
    end

    it 'the preconditions are correct' do
      expect(@library_books_before[@utopia].owned).to eq 1
      expect(@library_books_before[@utopia].in_circulation).to eq 0
      expect(@patron_books_before[@utopia].borrowed).to eq 1
    end

    it 'updates the library' do
      expect(@library.books[@utopia].owned).to eq 1
      expect(@library.books[@utopia].in_circulation).to eq 1
    end

    it 'updates the patron' do
      expect(@fulan.borrowing?(@utopia)).to be_falsey
    end

    it 'raise a patron returned book event' do
      expect(PatronReturnedBookEvent.any?(book: @utopia, patron: @fulan, library: @library)).to be_truthy
    end

    it 'raise a library accepted return book event' do
      expect(LibraryBookReturnAcceptedEvent.any?(book: @utopia, patron: @fulan, library: @library)).to be_truthy
    end
  end

  context 'trying to return a book' do
    before :all do
      @lending_library = Library.create 'sad path library loaning book to be returned'
      @returning_library = Library.create 'sad path library patron tries to return book to'
      @mujo = Patron.create 'Mujo Mujić'
      @lending_library.register_patron @mujo
      @fourth_circle = Book.create(title: 'The Fourth Circle', author: 'Zoran Živković')
      @lending_library.add @fourth_circle
      @lending_library.lend(book: @fourth_circle, patron: @mujo)
    end
    
    it 'will not return a book to the wrong library' do
      expect(@returning_library.owns?(@fourth_circle)).to be_falsey
      
      @mujo.return(book: @fourth_circle, library: @returning_library)

      expect(@lending_library.books[@fourth_circle].owned).to eq 1
      expect(@lending_library.books[@fourth_circle].in_circulation).to eq 0
      expect(@mujo.books[@fourth_circle].borrowed).to eq 1
    end
  end
end

# frozen_string_literal: true
# encoding: utf-8

require 'Timecop'
require_relative '../lib/domain/author.rb'
require_relative '../lib/domain/book.rb'
require_relative '../lib/domain/library.rb'
require_relative '../lib/dispositions/library_book_disposition.rb'
require_relative '../lib/domain/patron.rb'

RSpec.describe 'the event store' do
  context 'dispatching an event' do
    it 'will error if tries to store a non-event' do
      expect { EventStore.store 'invalid' }.to raise_error RuntimeError
    end
  end

  context 'getting the latest version of' do
    context 'an author' do
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

    context 'a book' do
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

    context 'a library' do
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

    context 'a patron' do
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

    context 'items after events that impact multiple objects' do
      before :all do
        @library = Library.create 'event store testing lending library'
        @jan = Patron.create 'Jan Alleman'
        @name_of_the_wind = Book.create(title: 'The Name of the Wind', author: 'Patrick Rothfuss')
        @library.add @name_of_the_wind
        @library.register_patron @jan
        @library.lend(book: @name_of_the_wind, patron: @jan)
      end

      it 'captures updates to the library' do
        stored_library = Library.get(@library.id)
        expect(stored_library.books).to eq @library.books
        expect(stored_library.patrons).to eq @library.patrons
        expect(stored_library).to eq @library
      end

      it 'captures updates to the patron' do
        stored_patron = Patron.get(@jan.id)
        expect(stored_patron).to eq @jan
      end

      it 'captures updates to the book' do
        stored_book = Book.get(@name_of_the_wind.id)
        expect(stored_book).to eq @name_of_the_wind
      end

      it 'captures updates to the author' do
        stored_author = Author.get(@name_of_the_wind.author.id)
        expect(stored_author.name).to eq 'Patrick Rothfuss'
      end
    end
  end

  context 'getting a version at a specified time' do
    context 'a library' do
      before :all do
        @clocktower = Time.local(1955, 11, 12, 10, 4, 0)
        Timecop.freeze(@clocktower)
        @library = Library.create 'get by id and time test library'
        Timecop.freeze(60)
        @back_to_the_future = Book.create(title: 'Back to the Future', author: 'George Gipe')
        Timecop.freeze(60)
        @library.add @back_to_the_future
        Timecop.freeze(60)
        @library.remove @back_to_the_future
      end

      after do
        Timecop.return
      end

      it 'retrieves the current version of the library by default' do
        expect(Time.now).to eq(@clocktower + 180)
        subject = Library.get(@library.id)
        expect(subject.id).to eq(@library.id)
        expect(subject.timestamp).to eq(@library.timestamp)
        expect(subject.owns?(@back_to_the_future)).to be_falsey
        expect(subject.books.size).to eq 0
      end

      it 'the event store contains the expected events at the given times' do
        expect(events_at(@clocktower) { |e| @back_to_the_future.id == e.book.id }.map(&:class)).to be_empty
        expect(events_at(@clocktower) { |e| @library.id == e.library.id }.map(&:class)).to contain_exactly LibraryCreatedEvent

        expect(events_at(@clocktower + 61) { |e| @back_to_the_future.id == e.book.id }.map(&:class)).to contain_exactly BookCreatedEvent
        expect(events_at(@clocktower + 61) { |e| @library.id == e.library.id }.map(&:class)).to contain_exactly LibraryCreatedEvent

        expect(events_at(@clocktower + 121) { |e| @back_to_the_future.id == e.book.id }.map(&:class)).to contain_exactly BookCreatedEvent, BookCopyAddedEvent
        expect(events_at(@clocktower + 121) { |e| @library.id == e.library.id }.map(&:class)).to contain_exactly LibraryCreatedEvent, BookCopyAddedEvent

        expect(events_at(@clocktower + 181) { |e| @back_to_the_future.id == e.book.id }.map(&:class)).to contain_exactly BookCreatedEvent, BookCopyAddedEvent, BookCopyRemovedEvent
        expect(events_at(@clocktower + 181) { |e| @library.id == e.library.id }.map(&:class)).to contain_exactly LibraryCreatedEvent, BookCopyAddedEvent, BookCopyRemovedEvent
      end

      it 'the event store contains the expected event contents at the given times' do
        events = events_at(@clocktower + 121) { |e| @library.id == e.library.id }
        expect(events.size).to eq 2

        expect(events[0].class).to eq LibraryCreatedEvent
        expect(events[0].library.id).to eq @library.id
        expect(events[0].library.books.collection).to eq({})

        expect(events[1].class).to eq BookCopyAddedEvent
        expect(events[1].library.id).to eq @library.id
        expect(events[1].book.id).to eq @back_to_the_future.id
        expect(events[1].book.title).to eq @back_to_the_future.title
        expect(events[1].library.books.collection).to eq(@back_to_the_future => LibraryBookDisposition.new(owned: 1, in_circulation: 1))
        expect(events[1].library.books.collection.keys.map(&:title)).to eq([@back_to_the_future.title])
      end

      it 'retrieves the state of the library at an given time', focus: true do
        subject = Library.get(@library.id, @clocktower + 121)
        expect(subject.id).to eq(@library.id)
        expect(subject.timestamp).to eq(@clocktower + 120)
        expect(subject.patrons.size).to eq 0
        expect(subject.books.size).to eq 1
        expect(subject.books.collection.keys.first).to eq @back_to_the_future
      end

      # it 'LAB retrieves the state of the library at an given time', focus: true do
      #   events = events_at(@clocktower + 121) { |e| @library.id == e.library.id }
      #   subject = Library.new
      #   events.each { |e| e.apply_to(subject) }
        
      #   expect(subject.id).to eq(@library.id)
      #   expect(subject.timestamp).to eq(@clocktower + 120)
      #   expect(subject.patrons.size).to eq 0
      #   expect(subject.books.size).to eq 1
      # end

      def events_at(time)
        events = EventStore.instance.find_all do |e|
          begin
            time >= e.timestamp && yield(e)
          rescue NoMethodError
            false
          end
        end.sort_by(&:timestamp)
        events
      end
    end
  end
end

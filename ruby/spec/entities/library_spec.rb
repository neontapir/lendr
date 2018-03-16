# frozen_string_literal: true
# encoding: utf-8

require 'timecop'
require 'uuid'
require_relative '../../lib/domain/book.rb'
require_relative '../../lib/domain/library.rb'
require_relative '../../lib/domain/patron.rb'

RSpec.describe 'the library' do
  let(:subject) { Library.create 'the library spec' }
  context 'a new library' do
    it 'should have a valid UUID as an identifier' do
      expect(UUID.validate(subject.id)).to be_truthy
    end

    it 'should have an empty books collection' do
      expect(subject.books).to be_empty
    end

    it 'should have an empty patrons collection' do
      expect(subject.patrons).to be_empty
    end

    it 'should have a current timestamp' do
      instant = Time.local(2008, 9, 1, 12, 0, 0) # arbitrary
      Timecop.freeze instant
      expect(Library.create('timestamp test library').timestamp).to eq(instant)
      Timecop.return
    end

    it 'should raise a creation event' do
      expect(subject).not_to be_nil # force let to be evaluated
      subject_created = EventStore.instance.any? do |e|
        e.is_a?(LibraryCreatedEvent) && e.library.id == subject.id
      end
      expect(subject_created).to be_truthy
    end
  end

  context 'adding a book to the library collection' do
    it 'should dispatch a book copy added event' do
      book = Book.create(title: 'The Little Prince',
                         author: 'Antoine de Saint-Exupéry')
      subject.add book
      expect(BookCopyAddedEvent.any?(book: book, library: subject)).to be_truthy
    end

    it 'a new book results in 1 copy in the library' do
      library = Library.create 'single copy library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, LibraryBookDisposition.new(owned: 1, in_circulation: 1)])
    end

    it 'an existing book increments the quantity of that book by 1' do
      library = Library.create 'multiple copies library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      library.add little_prince
      expect(library.books).to contain_exactly([little_prince, LibraryBookDisposition.new(owned: 2, in_circulation: 2)])
    end

    it 'a new book can be added to a library that already has a different book' do
      library = Library.create 'multiple books library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince
      expect(library.books).to include(little_prince)
      expect(library.books[little_prince]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)

      dune = Book.create(title: 'Dune',
                         author: 'Frank Herbert')
      library.add dune

      expect(library.books[little_prince]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)
      expect(library.books[dune]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)
    end

    it 'a new book can be added with multiple books in the library' do
      library = Library.create 'multiple books addition library'
      little_prince = Book.create(title: 'The Little Prince',
                                  author: 'Antoine de Saint-Exupéry')
      library.add little_prince

      dune = Book.create(title: 'Dune',
                         author: 'Frank Herbert')
      library.add dune
      library.add dune

      expect(library.books[little_prince]).to eq LibraryBookDisposition.new(owned: 1, in_circulation: 1)
      expect(library.books[dune]).to eq LibraryBookDisposition.new(owned: 2, in_circulation: 2)
    end

    it 'should raise an error when requested to add a non-book' do
      patron = Patron.new name: 'John Smith'
      expect{ subject.add patron }.to raise_error ArgumentError
      expect(BookCopyAddedEvent.any?(book: patron, library: subject)).to be_falsey
    end
  end

  context 'removing a book from the library collection' do
    it 'should raise a book copy removed event' do
      subject = Library.create 'the removing books library'
      book = Book.create(title: 'The Little Prince',
                         author: 'Antoine de Saint-Exupéry')
      subject.add book
      subject.remove book

      book_removed = EventStore.instance.any? do |e|
        e.is_a?(BookCopyRemovedEvent) &&
          e.book.id == book.id &&
          e.library.id == subject.id
      end
      expect(book_removed).to be_truthy
    end

    it 'means 1 less copy owned by the library' do
      subject = Library.create 'removing 1984 library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')
      subject.add nineteen_eighty_four
      subject.add nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, LibraryBookDisposition.new(owned: 2, in_circulation: 2)])

      subject.remove nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, LibraryBookDisposition.new(owned: 1, in_circulation: 1)])
    end

    it 'removes it from the library\'s collection if it is the last book owned' do
      subject = Library.create 'removing all 1984 copies library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')
      subject.add nineteen_eighty_four
      expect(subject.books).to contain_exactly([nineteen_eighty_four, LibraryBookDisposition.new(owned: 1, in_circulation: 1)])

      subject.remove nineteen_eighty_four
      expect(subject.books).to be_empty
    end

    it 'removing a non-existant book is a no-op' do
      subject = Library.create 'removing book from empty library'
      nineteen_eighty_four = Book.create(title: '1984',
                                         author: 'George Orwell')

      subject.remove nineteen_eighty_four
      expect(subject.books).to be_empty
      expect(BookCopyRemovedEvent.any?(book: nineteen_eighty_four, library: subject)).to be_falsey
    end
  end

  context 'registering a new patron' do
    it 'should raise a patron registered event' do
      patron = Patron.create 'John Doe'
      subject.register_patron patron

      expect(PatronRegisteredEvent.any?(patron: patron, library: subject)).to be_truthy
    end

    it 'puts the person in good standing' do
      patron = Patron.create 'Jane Doe'
      subject.register_patron patron
      expect(subject.patrons[patron].standing).to eq :good
    end

    it 'should not affect the standing of the patron at a different library' do
      library1 = Library.create 'First library for registering patrons'
      library2 = Library.create 'Second library for registering patrons'
      patron = Patron.create 'Jane Doe'
      library1.register_patron patron

      expect(library1.patrons[patron].standing).to eq :good
      expect(library2.patron?(patron)).to be_falsey
    end

    it 'should raise an error when requested to register a non-patron' do
      book = Book.new(title: 'Pride & Prejudice', author: 'Jane Austen')
      expect{ subject.register_patron book }.to raise_error ArgumentError
      expect(PatronRegisteredEvent.any?(patron: book, library: subject)).to be_falsey
    end
  end

  context 'lending an available book' do
    before :all do
      @library = Library.create 'happy path lending library'
      @pierre = Patron.create 'Pierre "Happy Path" Toulemonde'
      @left_hand_darkness = Book.create(title: 'The Left Hand of Darkness', author: 'Ursula K. LeGuin')
      @library.add @left_hand_darkness
      @library.add @left_hand_darkness
      @library_before = Marshal.load(Marshal.dump(@library))
      @patron_before = Marshal.load(Marshal.dump(@pierre))
      @library.register_patron @pierre
      @library.lend(book: @left_hand_darkness, patron: @pierre)
    end

    it 'the preconditions are correct' do
      expect(@library_before.owns?(@left_hand_darkness)).to be_truthy
      expect(@library_before.books[@left_hand_darkness].owned).to eq 2
      expect(@library_before.books[@left_hand_darkness].in_circulation).to eq 2
      expect(@patron_before.borrowing?(@left_hand_darkness)).to be_falsey
    end

    it 'raise a book leant event' do
      expect(LibraryLeantBookEvent.any?(book: @left_hand_darkness, patron: @pierre, library: @library)).to be_truthy
    end

    it 'raise a patron borrowed event' do
      expect(PatronBorrowedBookEvent.any?(book: @left_hand_darkness, patron: @pierre, library: @library)).to be_truthy
    end

    it 'removes a copy of the book from circulation' do
      expect(@library.books[@left_hand_darkness].owned).to eq 2
      expect(@library.books[@left_hand_darkness].in_circulation).to eq 1
    end

    it 'becomes borrowed by the patron' do
      expect(@pierre.books[@left_hand_darkness].borrowed).to eq 1
    end

    it 'is reflected in the event store' do
      the_library = Library.get(@library.id)
      expect(the_library.books[@left_hand_darkness].owned).to eq 2
      expect(the_library.books[@left_hand_darkness].in_circulation).to eq 1
    end
  end

  context 'trying to lend a book' do
    before :all do
      @library = Library.create 'sad path lending library'
      @jacque = Patron.create 'Jacque "Sad Path" Toulemonde'
      @library.register_patron @jacque
      @dragonriders = Book.create(title: 'The Dragonriders of Pern', author: 'Anne McCaffrey')
      @library.add @dragonriders
    end

    it 'will not lend a book to a person who is not registered as a patron' do
      michelle = Patron.create 'Michelle "Not a Patron" Toulemonde'
      @library.lend(book: @dragonriders, patron: michelle)
      expect(LibraryLeantBookEvent.any?(book: @dragonriders, patron: michelle, library: @library)).to be_falsey
      expect(PatronBorrowedBookEvent.any?(book: @dragonriders, patron: michelle, library: @library)).to be_falsey
    end

    it 'will not lend a book the library does not own' do
      neuromancer = Book.new(title: 'Neuromancer', author: 'William Gibson')
      expect(@library.owns?(neuromancer)).to be_falsey

      @library.lend(book: neuromancer, patron: @jacque)
      expect(LibraryLeantBookEvent.any?(book: neuromancer, patron: @jacque, library: @library)).to be_falsey
      expect(PatronBorrowedBookEvent.any?(book: neuromancer, patron: @jacque, library: @library)).to be_falsey
    end

    it 'will not lend a book with no copies in circulation' do
      copies_in_circulation = @library.books[@dragonriders].in_circulation
      expect(copies_in_circulation.positive?).to be_truthy
      @library.books.update(@dragonriders) { |b| b.subtract_in_circulation(copies_in_circulation) }
      expect(@library.in_circulation?(@dragonriders)).to be_falsey

      @library.lend(book: @dragonriders, patron: @jacque)
      expect(LibraryLeantBookEvent.any?(book: @dragonriders, patron: @jacque, library: @library)).to be_falsey
      expect(PatronBorrowedBookEvent.any?(book: @dragonriders, patron: @jacque, library: @library)).to be_falsey

      @library.books.update(@dragonriders) { |b| b.add_in_circulation(copies_in_circulation) }
      expect(@library.books[@dragonriders].in_circulation).to eq copies_in_circulation
    end

    it 'will not lend a book to a patron in bad standing' do
      alice = Patron.create 'Alice "Not a Patron" Toulemonde'
      @library.register_patron alice
      @library.revoke_borrowing alice

      @library.lend(book: @dragonriders, patron: alice)
      expect(LibraryLeantBookEvent.any?(book: @dragonriders, patron: alice, library: @library)).to be_falsey
      expect(PatronBorrowedBookEvent.any?(book: @dragonriders, patron: alice, library: @library)).to be_falsey
    end
  end

  context "changing a patron's standing" do
    before :all do
      @library = Library.new name: "天津滨海图书馆 'The Eye'"
    end

    it 'can change a patron from good to poor standing' do
      siu = Patron.new name: 'Wong Siu Ming'
      @library.register_patron siu
      @library.revoke_borrowing siu
      expect(@library.patrons[siu].standing).to eq :poor
    end

    it 'can change a patron in poor standing back to good' do
      tai = Patron.new name: 'Chan Tai Man'
      @library.register_patron tai
      @library.revoke_borrowing tai
      expect(@library.patrons[tai].standing).to eq :poor
    end

    it 'can change a patron in poor standing back to good' do
      san = Patron.new name: 'Zhang San'
      @library.register_patron san
      @library.revoke_borrowing san
      @library.allow_borrowing san
      expect(@library.patrons[san].standing).to eq :good
    end
  end
end

# frozen_string_literal: true
# encoding: utf-8

require_relative '../../lib/collections/books.rb'

RSpec.describe 'the books collection' do
  it 'the update method updates the disposition in the books collection' do
    books = Books.create_for_library
    hobbit = Book.new(title: 'The Hobbit', author: 'J.R.R. Tolkien')

    books.add(hobbit).update(hobbit) { |book| book.add_owned 1 }
    expect(books[hobbit].owned).to eq 1

    books[hobbit].add_owned 1
    expect(books[hobbit].owned).to eq 1
  end

  it "updating a book's disposition directly does not update the books collection" do
    books = Books.create_for_library
    hobbit = Book.new(title: 'The Hobbit', author: 'J.R.R. Tolkien')
    books.add(hobbit)

    books.update(hobbit) { |book| book.add_owned 1 }
    expect(books[hobbit].owned).to eq 1

    books[hobbit].add_owned 10
    expect(books[hobbit].owned).to eq 1
  end
end

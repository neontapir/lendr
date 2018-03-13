# frozen_string_literal: true
# encoding: utf-8

require_relative '../lib/library_books.rb'

RSpec.describe 'the library books collection' do
  it "updating a book's disposition directly updates the books collection" do
    pending "add methods return new object, so this collection's object is not updated -- implement observable?"

    books = LibraryBooks.new
    hobbit = Book.new(title: 'The Hobbit', author: 'J.R.R. Tolkien')
    books[hobbit] = LibraryBookDisposition.new(owned: 1, in_circulation: 1)
    expect(books[hobbit].owned).to eq 1
    books[hobbit].add_owned 1
    expect(books[hobbit].owned).to eq 2
  end
end

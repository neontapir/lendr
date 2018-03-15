# frozen_string_literal: true

require_relative 'author.rb'
require_relative 'entity.rb'
require_relative 'events/book_created_event.rb'

class Book < Entity
  attr_reader :title, :author

  def self.create(title:, author:)
    book = find_by_attributes { |event| title == event.book.title && author == event.book.author.name }
    unless book
      book = Book.new(title: title, author: Author.create(author))
      BookCreatedEvent.dispatch book: book
    end
    book
  end

  private

  def initialize(title: nil, author: nil)
    super()
    @title = title
    @author = author
  end
end

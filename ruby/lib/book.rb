# frozen_string_literal: true

require_relative 'entity.rb'
require_relative 'events/book_created_event.rb'

class Book < Entity
  attr_reader :name, :author

  def self.create(name:, author:)
    book = find_by_attributes { |event| name == event.book.name && author == event.book.author }
    unless book
      book = Book.new(name: name, author: author)
      BookCreatedEvent.raise book
    end
    book
  end

  def self.get(id)
    find_by_id(id) { |event| event.book.id }
  end

  def to_s
    "Book { id: '#{id}' }"
  end

  private

  def initialize(name: nil, author: nil)
    super()
    @name = name
    @author = author
  end
end

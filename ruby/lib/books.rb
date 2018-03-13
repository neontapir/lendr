# frozen_string_literal: true

require 'forwardable'
require_relative 'entity.rb'
require_relative 'library_book_disposition.rb'
require_relative 'patron_book_disposition.rb'

class Books < Entity
  extend Forwardable

  def self.create_library
    Books.new LibraryBookDisposition.none
  end

  def self.create_patron
    Books.new PatronBookDisposition.none
  end

  def [](book)
    @list[book]
  end

  def add(book)
    @list[book] = @default_value
    self
  end

  def update(book)
    @list[book] = yield @list[book]
    self
  end

  def_delegators :@list, :empty?, :size, :map, :key?,
                 :delete, :include?, :each, :each_pair, :to_a, :to_s

  private

  def initialize(default_value)
    super()
    @default_value = default_value
    @list = {}
  end
end

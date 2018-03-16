# frozen_string_literal: true

require 'forwardable'
require_relative '../domain/entity.rb'
require_relative '../dispositions/library_book_disposition.rb'
require_relative '../dispositions/patron_book_disposition.rb'

class Books < Entity
  extend Forwardable

  def self.create_for_library
    Books.new LibraryBookDisposition.none
  end

  def self.create_for_patron
    Books.new PatronBookDisposition.none
  end

  def collection
    @list.dup
  end

  def [](book)
    @list[book]
  end

  def add(book)
    @list[book] = @initial_disposition
    self
  end

  def update(book)
    @list[book] = yield @list[book]
    self
  end

  def_delegators :@list, :empty?, :size, :map, :key?,
                 :delete, :include?, :each, :each_pair, :to_a, :to_s

  private

  def initialize(initial_disposition, list = {})
    super()
    @initial_disposition = initial_disposition
    @list = list
  end
end

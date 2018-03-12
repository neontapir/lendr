# frozen_string_literal: true

require 'forwardable'
require_relative 'books.rb'
require_relative 'library_book_disposition.rb'

class LibraryBooks < Books
  extend Forwardable

  def initialize(list = Hash.new(LibraryBookDisposition.none))
    super()
    @list = list
  end
end

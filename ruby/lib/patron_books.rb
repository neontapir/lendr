# frozen_string_literal: true

require 'forwardable'
require_relative 'books.rb'
require_relative 'patron_book_disposition.rb'

class PatronBooks < Books
  extend Forwardable

  def initialize(list = Hash.new(PatronBookDisposition.none))
    super()
    @list = list
  end
end

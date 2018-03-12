# frozen_string_literal: true

class PatronBookDisposition
  attr_accessor :borrowed

  def self.none
    PatronBookDisposition.new(borrowed: 0)
  end

  def initialize(borrowed:)
    @borrowed = borrowed
  end

  def add_borrowed(quantity)
    PatronBookDisposition.new(borrowed: borrowed + quantity)
  end

  def subtract_borrowed(quantity)
    add_borrowed(-1 * quantity)
  end

  def ==(other)
    self.class == other.class &&
      borrowed == other.borrowed
  end

  alias_method :eql?, :==

  def hash
    borrowed.hash
  end
end

# frozen_string_literal: true

require 'observer'

class LibraryBookDisposition
  attr_accessor :owned, :in_circulation

  def self.none
    LibraryBookDisposition.new(owned: 0, in_circulation: 0).freeze
  end

  def initialize(owned:, in_circulation:)
    @owned = owned
    @in_circulation = in_circulation
  end

  def add_owned(quantity)
    LibraryBookDisposition.new(owned: [owned + quantity, 0].max, in_circulation: in_circulation)
  end

  def subtract_owned(quantity)
    add_owned(-1 * quantity)
  end

  def add_in_circulation(quantity)
    LibraryBookDisposition.new(owned: owned, in_circulation: [in_circulation + quantity, 0].max)
  end

  def subtract_in_circulation(quantity)
    add_in_circulation(-1 * quantity)
  end

  def ==(other)
    self.class == other.class &&
      owned == other.owned &&
      in_circulation == other.in_circulation
  end

  alias_method :eql?, :==

  def hash
    owned.hash ^ in_circulation.hash
  end

  def to_s
    "LibraryBookDisposition: { owned: #{owned}, in_circulation: #{in_circulation} }"
  end
end

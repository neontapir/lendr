# frozen_string_literal: true

class PatronDisposition
  attr_accessor :standing

  STANDINGS = [:none, :good].freeze

  def self.none
    PatronDisposition.new(:none)
  end

  def self.good
    PatronDisposition.new(:good)
  end

  def initialize(standing)
    @standing = standing
  end

  def change_standing(new_standing)
    raise ArgumentError unless STANDINGS.include? new_standing
    PatronDisposition.new(new_standing)
  end

  def ==(other)
    self.class == other.class &&
      standing == other.standing
  end

  alias_method :eql?, :==

  def hash
    standing.hash
  end
end

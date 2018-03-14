# frozen_string_literal: true

class PatronDisposition
  attr_reader :standing

  STANDINGS = %i[none good poor].freeze

  def self.none
    PatronDisposition.new(:none)
  end

  def self.good
    PatronDisposition.new(:good)
  end

  def self.poor
    PatronDisposition.new(:poor)
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

# frozen_string_literal: true

require 'forwardable'
require_relative 'patron_disposition.rb'
require_relative 'entity.rb'

class Patrons < Entity
  extend Forwardable

  def initialize(list = Hash.new(PatronDisposition.none))
    super()
    @list = list
  end

  def_delegators :@list, :empty?, :[], :[]=, :size, :map, :key?,
                 :delete, :include?, :each, :each_pair, :to_a
end

# frozen_string_literal: true

require 'forwardable'
require_relative 'entity.rb'

class Books < Entity
  extend Forwardable

  def initialize(list = Hash.new(0))
    super()
    @list = list
  end

  def_delegators :@list, :empty?, :[], :[]=, :size, :map, :key?,
                 :delete, :include?, :each, :each_pair, :to_a
end

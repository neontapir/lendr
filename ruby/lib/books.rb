# frozen_string_literal: true

require 'forwardable'
require_relative 'entity.rb'

class Books < Entity
  extend Forwardable

  def initialize(list = [])
    super()
    @list = list
  end

  def_delegators :@list, :empty?, :<<, :size, :map, :include?, :to_a
end
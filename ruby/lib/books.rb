# frozen_string_literal: true

require 'forwardable'
require 'observer'
require_relative 'entity.rb'

class Books < Entity
  extend Forwardable

  def_delegators :@list, :empty?, :[], :[]=, :size, :map, :key?,
                 :delete, :include?, :each, :each_pair, :to_a, :to_s
end

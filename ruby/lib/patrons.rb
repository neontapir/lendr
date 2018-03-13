# frozen_string_literal: true

require 'forwardable'
require_relative 'patron_disposition.rb'
require_relative 'entity.rb'

class Patrons < Entity
  extend Forwardable

  def self.create
    Patrons.new PatronDisposition.none
  end

  def [](patron)
    @list[patron]
  end

  def add(patron)
    @list[patron] = @default_value
    self
  end

  def update(patron)
    @list[patron] = yield @list[patron]
    self
  end

  def_delegators :@list, :empty?, :size, :map, :key?,
                 :delete, :include?, :each, :each_pair, :to_a, :to_s

  private

  def initialize(default_value)
    super()
    @default_value = default_value
    @list = {}
  end
end

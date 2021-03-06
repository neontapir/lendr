# frozen_string_literal: true

require 'forwardable'
require_relative '../dispositions/patron_disposition.rb'
require_relative '../domain/entity.rb'

class Patrons < Entity
  extend Forwardable

  def self.create
    Patrons.new
  end

  def [](patron)
    @list[patron]
  end

  def add(patron)
    @list[patron] = PatronDisposition.none
    self
  end

  def update(patron)
    @list[patron] = yield @list[patron]
    self
  end

  def_delegators :@list, :empty?, :size, :map, :key?,
                 :delete, :include?, :each, :each_pair, :to_a, :to_s

  private

  def initialize(list = {})
    super()
    @list = list
  end
end

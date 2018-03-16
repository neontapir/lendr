# frozen_string_literal: true

require 'forwardable'
require 'singleton'
require_relative 'events/event.rb'

class EventStore
  include Singleton
  extend Forwardable

  def initialize(list = [])
    @list = list
  end

  def self.store(event)
    raise ArgumentError unless event.is_a?(Event)
    instance << Marshal.load( Marshal.dump(event) )
    true # no need to return whole event store
  end

  def_delegators :@list, :empty?, :<<, :size, :map, :any?,
                 :find, :find_all, :to_s
end

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
    raise unless event.is_a?(Event)
    instance << Marshal.load( Marshal.dump(event) )
  end

  def_delegators :@list, :empty?, :<<, :size, :map, :any?,
                 :find, :find_all, :to_s
end

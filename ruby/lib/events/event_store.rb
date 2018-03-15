# frozen_string_literal: true

require 'deep_clone' # performs better than Marshal.load( Marshal.dump(event) )
require 'forwardable'
require 'singleton'
require_relative 'event.rb'

class EventStore
  include Singleton
  extend Forwardable
  def initialize(list = [])
    @list = list
  end

  def collection
    @list.dup
  end

  def self.store(event)
    raise unless event.is_a?(Event)
    instance << DeepClone.clone(event)
  end

  def_delegators :@list, :empty?, :<<, :size, :map, :any?, 
                 :find, :find_all, :to_s
end

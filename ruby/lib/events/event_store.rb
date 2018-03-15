# frozen_string_literal: true

require 'forwardable'
require 'singleton'

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
    instance << Marshal.load( Marshal.dump(event) )
  end

  def_delegators :@list, :empty?, :<<, :size, :map, :any?, 
                 :find, :find_all, :to_s
end

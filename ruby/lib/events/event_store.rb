require 'forwardable'
require 'singleton'

class EventStore
  include Singleton
  extend Forwardable
  def initialize(list = [])
    @list = list
  end

  def_delegators :@list, :empty?, :<<, :size, :map, :any?
end

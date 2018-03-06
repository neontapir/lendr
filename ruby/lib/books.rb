require 'forwardable'
require_relative 'entity.rb'

class Books < Entity
  extend Forwardable
  
  def initialize(list = [])
    super()
    @list = list
  end

  def_delegators :@list, :empty?, :<<, :size, :map
end

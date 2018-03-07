require_relative '../entity.rb'

class Event < Entity
  attr_reader :type

  def initialize()
    super
  end

  def create_event?
    type == 'create'
  end
end

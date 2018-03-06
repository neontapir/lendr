require 'securerandom'
require_relative 'entity.rb'

class Entity
  attr_reader :id, :timestamp

  def initialize()
    @id = SecureRandom.uuid
    @timestamp = Time.now
  end
end

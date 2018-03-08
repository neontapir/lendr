# frozen_string_literal: true

require_relative 'entity.rb'
require_relative 'events/author_created_event.rb'

class Person < Entity
  attr_reader :name

  def to_s
    "Person { id: '#{id}' }"
  end

  private

  def initialize(name = nil)
    super()
    @name = name
  end
end

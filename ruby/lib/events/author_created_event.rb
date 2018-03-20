# frozen_string_literal: true

require_relative 'event.rb'

class AuthorCreatedEvent < Event
  def initialize(author:)
    super
  end

  def apply_to(projection)
    return unless projection.is_a?(Author)
    update(projection,
           :@id => author.id,
           :@timestamp => author.timestamp,
           :@name => author.name)
  end
end

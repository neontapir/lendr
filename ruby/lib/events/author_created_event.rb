# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class AuthorCreatedEvent < Event
  attr_reader :author

  def initialize(author:)
    super()
    @author = author
  end

  def apply_to(projection)
    projection.is_a?(Author) &&
      update(projection,
             :@id => author.id,
             :@timestamp => author.timestamp,
             :@name => author.name)
  end
end

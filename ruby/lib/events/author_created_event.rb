# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class AuthorCreatedEvent < Event
  attr_reader :author

  def initialize(author)
    super()
    @author = author
  end

  def self.raise(author)
    EventStore.instance << AuthorCreatedEvent.new(author)
  end

  def apply_to(projection)
    update(projection,
           :@id => author.id,
           :@timestamp => author.timestamp,
           :@name => author.name)
  end
end

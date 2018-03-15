# frozen_string_literal: true

require_relative 'person.rb'
require_relative 'events/author_created_event.rb'

class Author < Person
  def self.create(name)
    author = find_by_attributes { |event| name == event.author.name }
    unless author
      author = Author.new(name)
      AuthorCreatedEvent.raise author
    end
    author
  end

  def self.get(id, time = Time.now)
    find_by_id(id, time) { |event| event.author.id }
  end

  private

  def initialize(name = nil)
    super(name)
  end
end

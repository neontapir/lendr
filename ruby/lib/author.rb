# frozen_string_literal: true

require_relative 'entity.rb'
require_relative 'events/author_created_event.rb'

class Author < Entity
  attr_reader :name

  def self.create(name)
    author = find_by_attributes { |event| name == event.author.name }
    unless author
      author = Author.new(name)
      AuthorCreatedEvent.raise author
    end
    author
  end

  def self.get(id)
    find_by_attributes { |event| AuthorCreatedEvent.class == event.class && id == event.author.id }
  end

  def to_s
    "Author { id: '#{id}' }"
  end

  private

  def initialize(name = nil)
    super()
    @name = name
  end
end

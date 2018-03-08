# frozen_string_literal: true

require_relative 'person.rb'
require_relative 'events/patron_created_event.rb'

class Patron < Person
  attr_reader :books
  
  def self.create(name)
    patron = find_by_attributes { |event| name == event.patron.name }
    unless patron
      patron = Patron.new(name)
      PatronCreatedEvent.raise patron
    end
    patron
  end

  def self.get(id)
    find_by_attributes { |event| PatronCreatedEvent.class == event.class && id == event.patron.id }
  end

  def to_s
    "Patron { id: '#{id}' }"
  end

  private

  def initialize(name = nil)
    super(name)
    @books = Books.new
  end
end

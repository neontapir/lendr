# frozen_string_literal: true

require_relative 'event.rb'
require_relative 'event_store.rb'

class PatronRegisteredEvent < Event
  attr_reader :library, :patron

  def initialize(library:, patron:)
    super()
    @library = library
    @patron = patron
  end

  def self.any?(library:, patron:)
    EventStore.instance.any? do |e|
      e.is_a?(PatronRegisteredEvent) &&
        e.patron.id == patron.id &&
        e.library.id == library.id
    end
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@timestamp => timestamp,
             :@patrons => library.patrons)
  end
end

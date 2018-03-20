# frozen_string_literal: true

require_relative 'event.rb'

class PatronRegisteredEvent < Event
  def initialize(library:, patron:)
    super
  end

  def apply_to(projection)
    projection.is_a?(Library) &&
      update(projection,
             :@timestamp => timestamp,
             :@patrons => library.patrons)
  end
end

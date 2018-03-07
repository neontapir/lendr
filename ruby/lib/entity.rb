require 'securerandom'
require_relative 'entity.rb'

class Entity
  attr_reader :id, :timestamp

  def initialize()
    @id = SecureRandom.uuid
    @timestamp = Time.now
  end

  def self.get_by_id(id, &id_lookup)
    events = EventStore.instance.find_all do |e|
      begin
        id_lookup.call(e) == id
      rescue NoMethodError
        false
      end
    end.sort_by(&:timestamp)
    return nil if events.empty?

    projection = self.new
    events.each { |e| e.apply_to(projection) }
    projection
  end
end

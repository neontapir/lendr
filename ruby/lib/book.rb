require_relative 'entity.rb'
require_relative 'events/book_created_event.rb'

class Book < Entity
  attr_reader :name, :author

  def self.create(name:, author:)
    book = Book.new(name: name, author: author)
    BookCreatedEvent.raise book
    book
  end

  def self.get(id)
    events = EventStore.instance.find_all do |e|
      begin
        e.book.id == id
      rescue NoMethodError
        false
      end
    end.sort_by(&:timestamp)

    return nil if events.empty?

    projection = Book.new(name: nil, author: nil)
    events.each do |e|
      e.apply_to(projection)
    end
    projection
  end

  def to_s
    "Book { id: '#{id}' }"
  end

  private

  def initialize(name:, author:)
    super()
    @name = name
    @author = author
  end
end

require_relative 'books.rb'
require_relative 'entity.rb'
require_relative 'events/book_added_event.rb'
require_relative 'events/library_created_event.rb'

class Library < Entity
  attr_reader :books

  def self.create
    library = Library.new
    LibraryCreatedEvent.raise library
    library
  end

  def self.get(id)
    events = EventStore.instance.find_all do |e|
      begin
        e.library.id == id
      rescue NoMethodError
        false
      end
    end.sort_by(&:timestamp)

    return nil if events.empty?

    projection = Library.new
    events.each do |e|
      e.apply_to(projection)
    end
    projection
  end

  def add(book)
    @books << book
    BookAddedEvent.raise(library: self, book: book)
  end

  def to_s
    "Library { id: '#{id}' }"
  end

  private

  def initialize()
    super
    @books = Books.new
  end
end

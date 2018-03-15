# Lendr

Lendr demonstrates the use of an event store in a library lending domain. The event store itself is a simple collection, but it sufficient to handle the use cases presented within.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Support](#support)
- [Contributing](#contributing)

## Installation

At the moment, the functionality is only shown through unit tests. To get started, run `bundle` to install dependencies.

## Usage

Executing the test suite is as easy as executing `rspec` from the top-level Ruby folder of the project.

## Features

The major features Lendr supports are:

- creating a library
- managing the inventory of books within the library
- managing the patrons of the library
- managing the lending of books to patrons of the library
- managing the returning of books to the library by patrons
- its event store can reconstruct an entity as of now, or as of an arbitrary time in the past

From a recent run of RSpec:

▶ rspec

the author
  a new author
    should have a valid UUID as an identifier
    should have a name
    should raise a creation event
  trying to create an existing author
    should return the first one instead
    should not raise an author created event

the book
  a new book
    should have a valid UUID as an identifier
    should have a title and author
    should raise a book creation event
  trying to create an existing book
    should return the first one instead
    should not raise a book created event

the books collection
  the update method updates the disposition in the books collection
  updating a book's disposition directly does not update the books collection

the event
  raising an event
    checks the parameters

the event store
  dispatching an event
    will error if tries to store a non-event
  getting the latest version of
    an author
      retrieves the book if it exists
      returns nil if the book does not exist
    a book
      retrieves the book if it exists
      returns nil if the book does not exist
    a library
      retrieves the library if it exists
      returns nil if the library does not exist
      retrieves the updated library after a book is added
    a patron
      gets the patron if it exists
      returns nil if the patron does not exist
    items after events that impact multiple objects
      captures updates to the library
      captures updates to the patron
      captures updates to the book
      captures updates to the author
  getting a version at a specified time
    a library
      retrieves the current version of the library by default
      the event store contains the expected events at the given times
      the event store contains the expected event contents at the given times
      retrieves the state of the library at an given time

the library book disposition
  adding books
    the "none" object shows no copies owned or in circulation
    adding to owned returns a new object with more books owned
    adding to in circulation returns a new object with more books in circulation
  subtracting books
    subtracting from owned returns a new object with less books owned
    trying to subtract more books from owned than stock returns zero books owned
    subtracting from in circulation returns a new object with less books in circulation
    trying to subtract more books from in circulation than stock returns zero books in circulation

the library
  a new library
    should have a valid UUID as an identifier
    should have an empty books collection
    should have an empty patrons collection
    should have a current timestamp
    should raise a creation event
  adding a book to the library collection
    should raise a book copy added event
    a new book results in 1 copy in the library
    an existing book increments the quantity of that book by 1
    a new book can be added to a library that already has a different book
    a new book can be added with multiple books in the library
  removing a book from the library collection
    should raise a book copy removed event
    means 1 less copy owned by the library
    removes it from the library's collection if it is the last book owned
    removing a non-existant book is a no-op
  registering a new patron
    should raise a patron registered event
    puts the person in good standing
    should not affect the standing of the patron at a different library
  lending an available book
    the preconditions are correct
    raise a book leant event
    raise a patron borrowed event
    removes a copy of the book from circulation
    becomes borrowed by the patron
    is reflected in the event store
  trying to lend a book
    will not lend a book to a person who is not registered as a patron
    will not lend a book the library does not own
    will not lend a book with no copies in circulation
    will not lend a book to a patron in bad standing

the patron book disposition
  adding books
    the "none" object shows no copies borrowed
    adding to borrowed returns a new object with more books borrowed
  subtracting books
    subtracting from borrowed returns a new object with less books borrowed
    trying to subtract more books from borrowed than stock returns zero books borrowed

the patron
  a newly created patron
    should have a valid UUID as an identifier
    should have a name
    should have a empty collection of books
    should raise a creation event
  trying to create an already-existing patron
    should return the first one instead
    should not raise a patron created event
  returning a borrowed book
    the preconditions are correct
    updates the library
    updates the patron
    raise a patron returned book event
    raise a library accepted return book event
  trying to return a book
    will not return a book to the wrong library

the patrons collection
  the update method updates the disposition in the patrons collection
  updating a patron's standing directly does not update the patrons collection

### Conventions

The `Event` and `Entity` class contain some metaprogramming to simplify the code.

To create a new entity, do the following:

- create a new class that inherits from `Entity`
  - derive from `Person` for entities that represent people
- create read-only attributes for its characteristics
- define a `self.create` method that takes initialization parameters
  - the create method either:
    - returns an existing object, if it is already in the event store
    - otherwise, it creates a new one and stores it
  - use an existing entity as a template for the method body
- define a private `initialize` method so the entity creation events are dispatched

The process for adding a new event is also pretty straightforward:

- create a new class (example: `LibraryLeantBookEvent`) that inherits from Event
- define an intializer that takes the entities affected as arguments
  - use named arguments that are the same as the entity's class or override `Event.any?`
- add a method to the orchestrating entity (example: `Library.loan` or `Patron.return`)
  - add a require statement to the entity file to include the event file
  - your method should update the local objects, then dispatch your new event
- define an `apply_to(projection)` method with statements that:
  - check the projection's type
  - updates the properties on the projection to match what's stored in the event
- add a test to exercise check that the new event is fired

## Support

Please [open an issue](https://github.com/neontapir/lendr/issues/new) for support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/neontapir/lendr/compare/).
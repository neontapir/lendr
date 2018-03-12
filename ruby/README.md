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

From a recent run of RSpec:

▶ rspec

the author
  a new author
    should have a valid ID
    should have a name
    should raise a creation event
  trying to create an existing author
    should return the first one instead
    should not raise an author created event

the book
  a new book
    should have a valid ID
    should have a title and author
    should raise a book creation event
  trying to create an existing book
    should return the first one instead
    should not raise a book created event

the event store
  getting an author by id
    retrieves the book if it exists
    returns nil if the book does not exist
  getting a book by id
    retrieves the book if it exists
    returns nil if the book does not exist
  getting a library by id
    retrieves the library if it exists
    returns nil if the library does not exist
    retrieves the updated library after a book is added
  getting a patron by id
    gets the patron if it exists
    returns nil if the patron does not exist

the library
  a new library
    should have a valid UUID as an identifier
    should have an empty books collection
    should have an empty patrons collection
    should have a current timestamp
    should raise a creation event
  adding a book to the library
    should raise a book copy added event
    a new book results in 1 copy in the library
    an existing book increments the quantity of that book by 1
    a new book can be added to a library that already has a different book
    a new book can be added with multiple books in the library
  removing a book
    should raise a book copy removed event
    means 1 less copy owned by the library
    removes it from the library's collection if it is the last book owned
    removing a non-existant book is a no-op
  registering a new patron
    should raise a patron registered event
    puts the person in good standing
    should not affect the standing of the patron at a different library

the patron
  a newly created patron
    should have a valid ID
    should have a name
    should have a empty collection of books
    should raise a creation event
  trying to create an already-existing patron
    should return the first one instead
    should not raise a patron created event

## Support

Please [open an issue](https://github.com/neontapir/lendr/issues/new) for support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/neontapir/lendr/compare/).
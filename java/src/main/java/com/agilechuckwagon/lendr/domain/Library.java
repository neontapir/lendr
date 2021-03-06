package com.agilechuckwagon.lendr.domain;

import com.agilechuckwagon.lendr.domain.events.LibraryCreatedEvent;
import com.agilechuckwagon.lendr.domain.events.DomainEvents;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Created by Chuck Durfee on 3/2/18.
 */
@Component
public class Library {
    private UUID libraryId;
    private Books books;
    private DomainEvents domainEvents;

    @Autowired
    public Library() {
        this.libraryId = UUID.randomUUID();
        this.books = new Books();
        domainEvents.raise(new LibraryCreatedEvent(this));
    }

    public UUID getLibraryId() {
        return libraryId;
    }
    public Books getBooks() {
        return books;
    }

    @Override
    public String toString() {
        return "library{" +
                "libraryId='" + libraryId + '\'' +
                ", books='" + books +
                '}';
    }
}

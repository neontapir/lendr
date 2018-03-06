package com.agilechuckwagon.lendr.domain.events;

import com.agilechuckwagon.lendr.domain.Library;
import org.springframework.stereotype.Component;

/**
 * Created by Chuck Durfee on 3/5/18.
 */
@Component
public class LibraryCreatedEvent extends DomainEvent {
    public LibraryCreatedEvent(Library library) {
        super(library.getLibraryId());
    }
}

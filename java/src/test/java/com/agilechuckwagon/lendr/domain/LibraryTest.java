package com.agilechuckwagon.lendr.domain;

import com.agilechuckwagon.lendr.domain.events.LibraryCreatedEvent;
import com.agilechuckwagon.lendr.domain.events.DomainEvents;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Created by Chuck Durfee on 3/2/18.
 */
@SpringBootTest
@ExtendWith(SpringExtension.class)
public class LibraryTest {
    @Test
    void canCreate() {
        Library actual = new Library();
        assertNotNull(actual);
        assertTrue(actual.getBooks().isEmpty());
        assertTrue(DomainEvents.getInstance().stream().anyMatch(x -> x instanceof LibraryCreatedEvent &&
            x.getEntityId() == actual.getLibraryId()));
    }
}

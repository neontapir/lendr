package com.agilechuckwagon.lendr.domain;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Created by Chuck Durfee on 3/2/18.
 */
public class LibraryTest {
    @Test
    void canCreate() {
        int id = 1;
        Library actual = new Library(id);
        assertNotNull(actual);
        assertEquals(id, actual.getLibraryId());
        assertTrue(actual.getBooks().isEmpty());
    }
}

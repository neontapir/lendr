package com.agilechuckwagon.lendr.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Created by Chuck Durfee on 3/2/18.
 */
public class Library {

    private int libraryId;
    private Books books;

    public Library(@JsonProperty("id") int libraryId) {
        this.libraryId = libraryId;
        this.books = new Books();
    }

    public int getLibraryId() {
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

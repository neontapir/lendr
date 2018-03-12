package com.agilechuckwagon.lendr.domain;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Created by Chuck Durfee on 3/2/18. Naive definition just to get started.
 */
@Component
public class Book {
    private UUID bookId;
    private String bookName;
    private String bookAuthor;
    private String description;
    private String imageUrl;

    @Autowired
    public Book(String bookName, String bookAuthor, String description, String imageUrl) {
        this.bookId = UUID.randomUUID();
        this.bookName = bookName;
        this.bookAuthor = bookAuthor;
        this.description = description;
        this.imageUrl = imageUrl;
    }

    public UUID getbookId() {
        return bookId;
    }

    public void setbookId(UUID bookId) {
        this.bookId = bookId;
    }

    public String getbookName() {
        return bookName;
    }

    public void setbookName(String bookName) {
        this.bookName = bookName;
    }

    public String getbookAuthor() {
        return bookAuthor;
    }

    public void setbookAuthor(String bookAuthor) {
        this.bookAuthor = bookAuthor;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    @Override
    public String toString() {
        return "book{" +
                "bookId='" + bookId + '\'' +
                ", bookName='" + bookName + '\'' +
                ", bookAuthor='" + bookAuthor + '\'' +
                ", description='" + description + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                '}';
    }
}
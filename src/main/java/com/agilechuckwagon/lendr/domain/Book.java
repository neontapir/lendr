package com.agilechuckwagon.lendr.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Created by Chuck Durfee on 3/2/18. Naive definition just to get started.
 */
public class Book {
    private int bookId;
    private String bookName;
    private String bookAuthor;
    private String description;
    private String imageUrl;

    public Book(@JsonProperty("id") int bookId,
                @JsonProperty("name") String bookName,
                @JsonProperty("author") String bookAuthor,
                @JsonProperty("description") String description,
                @JsonProperty("image") String imageUrl) {
        this.bookId = bookId;
        this.bookName = bookName;
        this.bookAuthor = bookAuthor;
        this.description = description;
        this.imageUrl = imageUrl;
    }

    public int getbookId() {
        return bookId;
    }

    public void setbookId(int bookId) {
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
                ", imageUrl='" + imageUrl +
                '}';
    }
}
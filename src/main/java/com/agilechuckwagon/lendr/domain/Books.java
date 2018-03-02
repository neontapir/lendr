package com.agilechuckwagon.lendr.domain;

import java.util.ArrayList;

/**
 * Created by Chuck Durfee on 3/2/18.
 */
public class Books extends ArrayList<Book> {
    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("books{");
        for(Book b : this) {
            sb.append(b);
            sb.append(", ");
        }
        sb.append('}');
        return sb.toString();
    }
}

package com.agilechuckwagon.lendr.domain.events;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Created by Chuck Durfee on 3/2/18.
 */
@Scope(value = "singleton")
@Repository
public final class DomainEvents extends ArrayList<DomainEvent> {
    @Autowired
    private final static AtomicReference<DomainEvents> INSTANCE = new AtomicReference<>();

    public DomainEvents() {
        final DomainEvents previous = INSTANCE.getAndSet(this);
        if(previous != null)
            throw new IllegalStateException("Second singleton " + this + " created after " + previous);
    }

    @Bean
    public static DomainEvents getInstance() {
        return INSTANCE.get();
    }

    public boolean raise(DomainEvent event) {
        add(event);
        return true;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("domainEvents{");
        for(DomainEvent event : getInstance()) {
            sb.append(event);
            sb.append(", ");
        }
        sb.append('}');
        return sb.toString();
    }
}
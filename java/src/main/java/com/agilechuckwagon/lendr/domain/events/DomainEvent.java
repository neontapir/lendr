package com.agilechuckwagon.lendr.domain.events;

import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.UUID;

/**
 * Created by Chuck Durfee on 3/5/18.
 */
@Component
public abstract class DomainEvent {
    private Instant timestamp;
    private UUID id;
    private UUID entityId;

    public DomainEvent(UUID entityId) {
        this.id = UUID.randomUUID();
        this.timestamp = Instant.now();
        this.entityId = entityId;
    }

    @Bean
    public UUID getId() {
        return id;
    }
    @Bean
    public Instant getTimestamp() {
        return timestamp;
    }
    @Bean
    public UUID getEntityId() {
        return entityId;
    }

    @Override
    public String toString() {
        String eventName = this.getClass().getSimpleName();
        return "domainEvent{" +
                "eventName='" + eventName + '\'' +
                ", timestamp='" + timestamp + '\'' +
                ", entityId='" + entityId + '\'' +
                '}';
    }
}

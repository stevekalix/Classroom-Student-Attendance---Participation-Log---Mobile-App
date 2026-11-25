package com.classtrack.entity;
import jakarta.persistence.*;
import java.time.Instant;
import lombok.Getter;
import lombok.Setter;
@MappedSuperclass @Getter @Setter
public abstract class BaseEntity {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @Column(nullable=false, updatable=false) private Instant createdAt;
 @Column(nullable=false) private Instant updatedAt;
 @PrePersist void create() { createdAt=updatedAt=Instant.now(); }
 @PreUpdate void update() { updatedAt=Instant.now(); }
}

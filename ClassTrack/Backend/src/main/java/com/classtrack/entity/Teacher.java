package com.classtrack.entity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import com.classtrack.enums.*;
@Getter @Setter @Entity @Table(name="teachers")
public class Teacher extends BaseEntity {
 @Column(nullable=false,length=150) private String fullName;
 @Column(nullable=false,unique=true,length=254) private String email;
 @Column(nullable=false) private String passwordHash;
 @Enumerated(EnumType.STRING) @Column(nullable=false,length=30) private Role role=Role.TEACHER;
}

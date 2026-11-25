package com.classtrack.entity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
@Getter @Setter @Entity @Table(name="students")
public class Student extends BaseEntity {
 @ManyToOne(fetch=FetchType.LAZY,optional=false) @JoinColumn(name="teacher_id") private Teacher teacher;
 @Column(nullable=false,length=150) private String fullName;
 @Column(nullable=false,length=50) private String rollId;
 @Column(nullable=false,length=100) private String className;
 @Column(nullable=false,length=100) private String subjectGroup;
 @Column(nullable=false) private LocalDate enrollmentDate;
 @Column(columnDefinition="TEXT") private String academicNotes;
 @Column(nullable=false) private boolean isActive=true;
}

package com.classtrack.entity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import com.classtrack.enums.*;
@Getter @Setter @Entity @Table(name="progress_notes")
public class ProgressNote extends BaseEntity {
 @ManyToOne(fetch=FetchType.LAZY,optional=false) @JoinColumn(name="student_id") private Student student;
 @ManyToOne(fetch=FetchType.LAZY,optional=false) @JoinColumn(name="teacher_id") private Teacher teacher;
 @Enumerated(EnumType.STRING) @Column(nullable=false,length=50) private NoteCategory category;
 @Column(nullable=false,columnDefinition="TEXT") private String content;
}

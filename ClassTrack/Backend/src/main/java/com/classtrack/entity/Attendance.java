package com.classtrack.entity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import com.classtrack.enums.*;
@Getter @Setter @Entity @Table(name="attendance")
public class Attendance extends BaseEntity {
 @ManyToOne(fetch=FetchType.LAZY,optional=false) @JoinColumn(name="student_id") private Student student;
 @Column(nullable=false) private LocalDate attendanceDate;
 @Enumerated(EnumType.STRING) @Column(nullable=false,length=20) private AttendanceStatus status;
}

package com.classtrack.repository;
import com.classtrack.entity.Attendance;
import java.time.LocalDate;
import java.util.*;
import org.springframework.data.jpa.repository.JpaRepository;
public interface AttendanceRepository extends JpaRepository<Attendance,Long> {
 Optional<Attendance> findByStudentIdAndAttendanceDate(Long id,LocalDate date);
 List<Attendance> findByStudentIdOrderByAttendanceDateDesc(Long id);
 List<Attendance> findByStudentTeacherIdAndAttendanceDateAndStudentIsActiveTrue(Long teacherId,LocalDate date);
 Optional<Attendance> findByIdAndStudentTeacherId(Long id,Long teacherId);
}

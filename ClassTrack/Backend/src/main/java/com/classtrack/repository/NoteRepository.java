package com.classtrack.repository;
import com.classtrack.entity.ProgressNote;
import java.util.*;
import org.springframework.data.jpa.repository.JpaRepository;
public interface NoteRepository extends JpaRepository<ProgressNote,Long> {
 List<ProgressNote> findByStudentIdAndTeacherIdOrderByUpdatedAtDesc(Long studentId,Long teacherId);
 List<ProgressNote> findTop5ByTeacherIdAndStudentIsActiveTrueOrderByUpdatedAtDesc(Long teacherId);
 Optional<ProgressNote> findByIdAndTeacherId(Long id,Long teacherId);
}

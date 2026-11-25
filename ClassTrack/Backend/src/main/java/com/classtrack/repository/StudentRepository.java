package com.classtrack.repository;
import com.classtrack.entity.Student;
import java.util.*;
import org.springframework.data.jpa.repository.*;
public interface StudentRepository extends JpaRepository<Student,Long>, JpaSpecificationExecutor<Student> {
 Optional<Student> findByIdAndTeacherId(Long id,Long teacherId);
 boolean existsByTeacherIdAndRollIdAndIdNot(Long teacherId,String rollId,Long id);
 List<Student> findByTeacherIdAndIsActiveTrue(Long teacherId);
 List<Student> findTop5ByTeacherIdAndIsActiveTrueOrderByCreatedAtDesc(Long teacherId);
}

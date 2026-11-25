package com.classtrack.repository;
import com.classtrack.entity.Teacher;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
public interface TeacherRepository extends JpaRepository<Teacher,Long> {
 Optional<Teacher> findByEmail(String email);
 boolean existsByEmail(String email);
}

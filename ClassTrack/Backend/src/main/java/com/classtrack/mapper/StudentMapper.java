package com.classtrack.mapper;
import com.classtrack.entity.Student;
import com.classtrack.dto.response.StudentResponse;
public final class StudentMapper {
 private StudentMapper() {}
 public static StudentResponse toResponse(Student s,String status) {
 return new StudentResponse(s.getId(),s.getFullName(),s.getRollId(),s.getClassName(),s.getSubjectGroup(),s.getEnrollmentDate(),s.getAcademicNotes(),s.isActive(),status);
 }
}

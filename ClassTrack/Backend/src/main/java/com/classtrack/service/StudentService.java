package com.classtrack.service;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import com.classtrack.entity.Student;
import java.time.LocalDate;
public interface StudentService {
 PageResponse<StudentResponse> list(String search,String className,String subjectGroup,String status,Boolean active,LocalDate date,int page,int size,String sort);
 Student owned(Long id); StudentResponse get(Long id); StudentResponse create(StudentRequest r); StudentResponse update(Long id,StudentRequest r); void delete(Long id);
}

package com.classtrack.service.impl;
import com.classtrack.service.*;
import com.classtrack.repository.*;
import com.classtrack.entity.*;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import com.classtrack.exception.*;
import com.classtrack.mapper.StudentMapper;
import com.classtrack.util.DateUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import jakarta.persistence.criteria.Predicate;
import java.time.LocalDate;
import java.util.*;
@Service @RequiredArgsConstructor @Transactional
public class StudentServiceImpl implements StudentService {
 private final StudentRepository students; private final AttendanceRepository attendance; private final AuthService auth;
 public Student owned(Long id) { return students.findByIdAndTeacherId(id,auth.current().getId()).orElseThrow(()->new ResourceNotFoundException("Student not found")); }
 private StudentResponse response(Student s,LocalDate date) { return StudentMapper.toResponse(s,attendance.findByStudentIdAndAttendanceDate(s.getId(),date).map(a->a.getStatus().name()).orElse("UNMARKED")); }
 public StudentResponse get(Long id) { return response(owned(id),DateUtils.today()); }
 public PageResponse<StudentResponse> list(String search,String className,String subjectGroup,String status,Boolean active,LocalDate date,int page,int size,String sort) {
 if(page<0||size<1||size>100) throw new IllegalArgumentException("Invalid page");
 if(status!=null && !Set.of("PRESENT","ABSENT","LATE","UNMARKED").contains(status)) throw new IllegalArgumentException("Invalid status");
 if(!Set.of("fullName","rollId","enrollmentDate","createdAt").contains(sort)) throw new IllegalArgumentException("Invalid sort");
 Long teacherId=auth.current().getId();
 Specification<Student> spec=(root,q,cb)-> {
 List<Predicate> p=new ArrayList<>();p.add(cb.equal(root.get("teacher").get("id"),teacherId));
 if(active!=null)p.add(cb.equal(root.get("isActive"),active));
 if(search!=null&&!search.isBlank()) { String term="%"+search.toLowerCase(Locale.ROOT).replace("\\","\\\\").replace("%","\\%").replace("_","\\_")+"%";p.add(cb.or(cb.like(cb.lower(root.get("fullName")),term,'\\'),cb.like(cb.lower(root.get("rollId")),term,'\\'))); }
 if(className!=null&&!className.isBlank())p.add(cb.equal(cb.lower(root.get("className")),className.toLowerCase(Locale.ROOT)));
 if(subjectGroup!=null&&!subjectGroup.isBlank())p.add(cb.equal(cb.lower(root.get("subjectGroup")),subjectGroup.toLowerCase(Locale.ROOT)));
 if(status!=null) { var sub=q.subquery(Long.class);var a=sub.from(Attendance.class);var match=cb.and(cb.equal(a.get("student").get("id"),root.get("id")),cb.equal(a.get("attendanceDate"),date));
 if(!status.equals("UNMARKED"))match=cb.and(match,cb.equal(a.get("status"),com.classtrack.enums.AttendanceStatus.valueOf(status)));
 sub.select(a.get("id")).where(match);p.add(status.equals("UNMARKED")?cb.not(cb.exists(sub)):cb.exists(sub)); }
 return cb.and(p.toArray(Predicate[]::new));
 };
 var result=students.findAll(spec,PageRequest.of(page,size,Sort.by(sort).ascending().and(Sort.by("id"))));
 return new PageResponse<>(result.getContent().stream().map(s->response(s,date)).toList(),page,result.getTotalPages(),result.getTotalElements());
 }
 public StudentResponse create(StudentRequest r) { Student s=new Student();s.setTeacher(auth.current());apply(s,r);students.saveAndFlush(s);return response(s,DateUtils.today()); }
 public StudentResponse update(Long id,StudentRequest r) { Student s=owned(id);apply(s,r);students.saveAndFlush(s);return response(s,DateUtils.today()); }
 private void apply(Student s,StudentRequest r) {
 if(students.existsByTeacherIdAndRollIdAndIdNot(s.getTeacher().getId(),r.rollId().strip(),s.getId()==null?0L:s.getId())) throw new DuplicateResourceException("Roll ID already exists");
 s.setFullName(r.fullName().strip());s.setRollId(r.rollId().strip());s.setClassName(r.className().strip());s.setSubjectGroup(r.subjectGroup().strip());s.setEnrollmentDate(r.enrollmentDate());s.setAcademicNotes(r.academicNotes());
 }
 public void delete(Long id) { Student s=owned(id);s.setActive(false);students.save(s); }
}

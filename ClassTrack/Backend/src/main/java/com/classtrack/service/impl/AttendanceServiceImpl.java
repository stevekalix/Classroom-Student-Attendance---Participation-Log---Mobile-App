package com.classtrack.service.impl;
import com.classtrack.service.*;
import com.classtrack.repository.*;
import com.classtrack.entity.*;
import com.classtrack.enums.AttendanceStatus;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import com.classtrack.exception.*;
import com.classtrack.mapper.AttendanceMapper;
import com.classtrack.util.DateUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.*;
@Service @RequiredArgsConstructor @Transactional
public class AttendanceServiceImpl implements AttendanceService {
 private final AttendanceRepository attendance;private final StudentService students;private final AuthService auth;
 public List<AttendanceResponse> daily(LocalDate date) { return attendance.findByStudentTeacherIdAndAttendanceDateAndStudentIsActiveTrue(auth.current().getId(),date).stream().map(AttendanceMapper::toResponse).toList(); }
 public AttendanceResponse save(AttendanceRequest r) {
 Student s=students.owned(r.studentId());
 if(!s.isActive())throw new ApiException(422,"INACTIVE_STUDENT","Cannot mark an inactive student");
 if(r.attendanceDate().isBefore(s.getEnrollmentDate()))throw new ApiException(422,"BEFORE_ENROLLMENT","Attendance cannot precede enrollment");
 Attendance a=attendance.findByStudentIdAndAttendanceDate(s.getId(),r.attendanceDate()).orElseGet(Attendance::new);
 a.setStudent(s);a.setAttendanceDate(r.attendanceDate());a.setStatus(r.status());return AttendanceMapper.toResponse(attendance.saveAndFlush(a));
 }
 public List<AttendanceResponse> bulk(BulkAttendanceRequest r) {
 Set<String> keys=new HashSet<>();for(var row:r.records())if(!keys.add(row.studentId()+"/"+row.attendanceDate()))throw new ApiException(400,"DUPLICATE_BATCH_ENTRY","Duplicate student/date in batch");
 return r.records().stream().map(this::save).toList();
 }
 public AttendanceResponse update(Long id,AttendanceRequest r) {
 Attendance a=attendance.findByIdAndStudentTeacherId(id,auth.current().getId()).orElseThrow(()->new ResourceNotFoundException("Attendance not found"));
 if(!a.getStudent().getId().equals(r.studentId()) || !a.getAttendanceDate().equals(r.attendanceDate()))throw new ApiException(400,"IMMUTABLE_ATTENDANCE_KEY","Student and date cannot change; update status only");
 a.setStatus(r.status());return AttendanceMapper.toResponse(attendance.saveAndFlush(a));
 }
 public List<AttendanceResponse> history(Long id) { students.owned(id);return attendance.findByStudentIdOrderByAttendanceDateDesc(id).stream().map(AttendanceMapper::toResponse).toList(); }
 public AttendanceSummary summary(Long id) { var list=history(id);long p=list.stream().filter(a->a.status()==AttendanceStatus.PRESENT).count(),l=list.stream().filter(a->a.status()==AttendanceStatus.LATE).count(),a=list.size()-p-l;return new AttendanceSummary(list.size(),p,a,l,DateUtils.percentage(p,l,list.size())); }
}

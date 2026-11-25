package com.classtrack.service.impl;
import com.classtrack.service.*;
import com.classtrack.repository.*;
import com.classtrack.dto.response.*;
import com.classtrack.mapper.*;
import com.classtrack.enums.AttendanceStatus;
import com.classtrack.util.DateUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
@Service @RequiredArgsConstructor @Transactional(readOnly=true)
public class DashboardServiceImpl implements DashboardService {
 private final StudentRepository students;private final AttendanceRepository attendance;private final NoteRepository notes;private final AuthService auth;
 public DashboardResponse summary(LocalDate date) {
 Long id=auth.current().getId();var roster=students.findByTeacherIdAndIsActiveTrue(id);var records=attendance.findByStudentTeacherIdAndAttendanceDateAndStudentIsActiveTrue(id,date);
 long p=records.stream().filter(a->a.getStatus()==AttendanceStatus.PRESENT).count(),l=records.stream().filter(a->a.getStatus()==AttendanceStatus.LATE).count(),a=records.size()-p-l;
 var recent=students.findTop5ByTeacherIdAndIsActiveTrueOrderByCreatedAtDesc(id).stream().map(s->StudentMapper.toResponse(s,records.stream().filter(r->r.getStudent().getId().equals(s.getId())).findFirst().map(r->r.getStatus().name()).orElse("UNMARKED"))).toList();
 return new DashboardResponse(roster.size(),p,a,l,roster.size()-records.size(),DateUtils.percentage(p,l,records.size()),recent,notes.findTop5ByTeacherIdAndStudentIsActiveTrueOrderByUpdatedAtDesc(id).stream().map(NoteMapper::toResponse).toList());
 }
}

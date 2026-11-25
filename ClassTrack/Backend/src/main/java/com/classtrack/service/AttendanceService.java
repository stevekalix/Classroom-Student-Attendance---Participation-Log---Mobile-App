package com.classtrack.service;
import java.time.LocalDate;
import java.util.List;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
public interface AttendanceService { List<AttendanceResponse> daily(LocalDate date); AttendanceResponse save(AttendanceRequest r); List<AttendanceResponse> bulk(BulkAttendanceRequest r); AttendanceResponse update(Long id,AttendanceRequest r); List<AttendanceResponse> history(Long studentId); AttendanceSummary summary(Long studentId); }

package com.classtrack.dto.response;
import java.time.*;
import com.classtrack.enums.*;
public record AttendanceResponse(Long id, Long studentId, LocalDate attendanceDate, AttendanceStatus status) {}

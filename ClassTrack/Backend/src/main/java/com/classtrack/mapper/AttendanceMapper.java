package com.classtrack.mapper;
import com.classtrack.entity.Attendance;
import com.classtrack.dto.response.AttendanceResponse;
public final class AttendanceMapper {
 private AttendanceMapper() {}
 public static AttendanceResponse toResponse(Attendance a) { return new AttendanceResponse(a.getId(),a.getStudent().getId(),a.getAttendanceDate(),a.getStatus()); }
}

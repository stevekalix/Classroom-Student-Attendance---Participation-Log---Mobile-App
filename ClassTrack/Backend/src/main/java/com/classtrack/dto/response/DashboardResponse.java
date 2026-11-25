package com.classtrack.dto.response;
import java.util.List;
public record DashboardResponse(long totalStudents, long presentCount, long absentCount, long lateCount, long unmarkedCount, double attendancePercentage, List<StudentResponse> recentStudents, List<NoteResponse> recentNotes) {}

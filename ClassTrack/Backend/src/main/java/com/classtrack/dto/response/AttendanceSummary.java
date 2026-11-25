package com.classtrack.dto.response;
public record AttendanceSummary(long totalDays, long presentDays, long absentDays, long lateDays, double attendancePercentage) {}

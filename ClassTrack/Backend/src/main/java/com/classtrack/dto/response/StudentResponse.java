package com.classtrack.dto.response;
import java.time.*;
public record StudentResponse(Long id, String fullName, String rollId, String className, String subjectGroup, LocalDate enrollmentDate, String academicNotes, boolean isActive, String attendanceStatus) {}

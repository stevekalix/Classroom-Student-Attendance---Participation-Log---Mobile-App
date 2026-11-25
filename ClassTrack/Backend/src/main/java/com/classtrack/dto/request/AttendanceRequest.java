package com.classtrack.dto.request;
import jakarta.validation.constraints.*;
import java.time.LocalDate;
import com.classtrack.enums.*;
public record AttendanceRequest(@NotNull @Positive Long studentId, @NotNull LocalDate attendanceDate, @NotNull AttendanceStatus status) {}

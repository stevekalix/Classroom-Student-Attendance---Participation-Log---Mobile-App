package com.classtrack.dto.request;
import jakarta.validation.constraints.*;
import java.time.LocalDate;
public record StudentRequest(@NotBlank @Size(max=150) String fullName, @NotBlank @Size(max=50) String rollId, @NotBlank @Size(max=100) String className, @NotBlank @Size(max=100) String subjectGroup, @NotNull LocalDate enrollmentDate, @Size(max=10000) String academicNotes) {}

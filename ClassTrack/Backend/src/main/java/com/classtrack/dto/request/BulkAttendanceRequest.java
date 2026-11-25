package com.classtrack.dto.request;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.util.List;
public record BulkAttendanceRequest(@NotEmpty @Size(max=500) List<@Valid AttendanceRequest> records) {}

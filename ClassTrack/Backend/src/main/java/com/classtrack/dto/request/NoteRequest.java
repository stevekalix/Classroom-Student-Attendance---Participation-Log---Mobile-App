package com.classtrack.dto.request;
import jakarta.validation.constraints.*;
import com.classtrack.enums.*;
public record NoteRequest(@NotNull NoteCategory category, @NotBlank @Size(max=10000) String content) {}

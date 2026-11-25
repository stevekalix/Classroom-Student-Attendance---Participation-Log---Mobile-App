package com.classtrack.dto.response;
import java.time.*;
import com.classtrack.enums.*;
public record NoteResponse(Long id, Long studentId, Long teacherId, NoteCategory category, String content, Instant createdAt, Instant updatedAt) {}

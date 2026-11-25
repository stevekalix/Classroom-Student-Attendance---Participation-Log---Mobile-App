package com.classtrack.mapper;
import com.classtrack.entity.ProgressNote;
import com.classtrack.dto.response.NoteResponse;
public final class NoteMapper {
 private NoteMapper() {}
 public static NoteResponse toResponse(ProgressNote n) { return new NoteResponse(n.getId(),n.getStudent().getId(),n.getTeacher().getId(),n.getCategory(),n.getContent(),n.getCreatedAt(),n.getUpdatedAt()); }
}

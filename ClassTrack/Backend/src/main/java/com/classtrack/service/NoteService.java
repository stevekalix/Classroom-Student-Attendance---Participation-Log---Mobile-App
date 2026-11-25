package com.classtrack.service;
import java.util.List;
import com.classtrack.dto.request.NoteRequest;
import com.classtrack.dto.response.NoteResponse;
public interface NoteService { List<NoteResponse> list(Long studentId); NoteResponse create(Long studentId,NoteRequest r); NoteResponse update(Long id,NoteRequest r); void delete(Long id); }

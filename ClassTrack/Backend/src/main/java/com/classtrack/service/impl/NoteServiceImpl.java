package com.classtrack.service.impl;
import com.classtrack.service.*;
import com.classtrack.repository.*;
import com.classtrack.entity.*;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import com.classtrack.exception.*;
import com.classtrack.mapper.NoteMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
@Service @RequiredArgsConstructor @Transactional
public class NoteServiceImpl implements NoteService {
 private final NoteRepository notes;private final StudentService students;private final AuthService auth;
 public List<NoteResponse> list(Long id) { students.owned(id);return notes.findByStudentIdAndTeacherIdOrderByUpdatedAtDesc(id,auth.current().getId()).stream().map(NoteMapper::toResponse).toList(); }
 public NoteResponse create(Long id,NoteRequest r) { ProgressNote n=new ProgressNote();n.setStudent(students.owned(id));n.setTeacher(auth.current());return apply(n,r); }
 public NoteResponse update(Long id,NoteRequest r) { return apply(owned(id),r); }
 private ProgressNote owned(Long id) { return notes.findByIdAndTeacherId(id,auth.current().getId()).orElseThrow(()->new ResourceNotFoundException("Note not found")); }
 private NoteResponse apply(ProgressNote n,NoteRequest r) { n.setCategory(r.category());n.setContent(r.content().strip());return NoteMapper.toResponse(notes.saveAndFlush(n)); }
 public void delete(Long id) { notes.delete(owned(id)); }
}

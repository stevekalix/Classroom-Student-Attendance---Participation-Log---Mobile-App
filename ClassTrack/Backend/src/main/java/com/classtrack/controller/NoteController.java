package com.classtrack.controller;
import com.classtrack.service.NoteService;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import java.util.List;
@RestController @RequestMapping("/api/v1") @RequiredArgsConstructor
public class NoteController {
 private final NoteService notes;
 @GetMapping("/students/{id}/notes") public ApiResponse<List<NoteResponse>> list(@PathVariable Long id) { return ApiResponse.ok(notes.list(id)); }
 @PostMapping("/students/{id}/notes") @ResponseStatus(HttpStatus.CREATED) public ApiResponse<NoteResponse> create(@PathVariable Long id,@Valid @RequestBody NoteRequest r) { return ApiResponse.ok(notes.create(id,r)); }
 @PatchMapping("/notes/{id}") public ApiResponse<NoteResponse> update(@PathVariable Long id,@Valid @RequestBody NoteRequest r) { return ApiResponse.ok(notes.update(id,r)); }
 @DeleteMapping("/notes/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void delete(@PathVariable Long id) { notes.delete(id); }
}

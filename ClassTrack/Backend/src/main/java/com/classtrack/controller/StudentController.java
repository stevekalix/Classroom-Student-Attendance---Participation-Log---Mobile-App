package com.classtrack.controller;
import com.classtrack.service.StudentService;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import com.classtrack.util.DateUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import java.time.LocalDate;
@RestController @RequestMapping("/api/v1/students") @RequiredArgsConstructor
public class StudentController {
 private final StudentService students;
 @GetMapping public ApiResponse<PageResponse<StudentResponse>> list(@RequestParam(required=false) String search,@RequestParam(required=false) String className,@RequestParam(required=false) String subjectGroup,@RequestParam(required=false) String status,@RequestParam(defaultValue="true") Boolean active,@RequestParam(required=false) LocalDate date,@RequestParam(defaultValue="0") int page,@RequestParam(defaultValue="20") int size,@RequestParam(defaultValue="fullName") String sort) { return ApiResponse.ok(students.list(search,className,subjectGroup,status,active,date==null?DateUtils.today():date,page,size,sort)); }
 @GetMapping("/{id}") public ApiResponse<StudentResponse> get(@PathVariable Long id) { return ApiResponse.ok(students.get(id)); }
 @PostMapping @ResponseStatus(HttpStatus.CREATED) public ApiResponse<StudentResponse> create(@Valid @RequestBody StudentRequest r) { return ApiResponse.ok(students.create(r)); }
 @PatchMapping("/{id}") public ApiResponse<StudentResponse> update(@PathVariable Long id,@Valid @RequestBody StudentRequest r) { return ApiResponse.ok(students.update(id,r)); }
 @DeleteMapping("/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void delete(@PathVariable Long id) { students.delete(id); }
}

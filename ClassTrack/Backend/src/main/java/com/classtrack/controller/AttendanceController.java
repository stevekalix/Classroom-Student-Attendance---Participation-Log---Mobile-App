package com.classtrack.controller;
import com.classtrack.service.AttendanceService;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;
@RestController @RequestMapping("/api/v1") @RequiredArgsConstructor
public class AttendanceController {
 private final AttendanceService attendance;
 @GetMapping("/attendance") public ApiResponse<List<AttendanceResponse>> daily(@RequestParam LocalDate date) { return ApiResponse.ok(attendance.daily(date)); }
 @PostMapping("/attendance") public ApiResponse<AttendanceResponse> save(@Valid @RequestBody AttendanceRequest r) { return ApiResponse.ok(attendance.save(r)); }
 @PostMapping("/attendance/bulk") public ApiResponse<List<AttendanceResponse>> bulk(@Valid @RequestBody BulkAttendanceRequest r) { return ApiResponse.ok(attendance.bulk(r)); }
 @PatchMapping("/attendance/{id}") public ApiResponse<AttendanceResponse> update(@PathVariable Long id,@Valid @RequestBody AttendanceRequest r) { return ApiResponse.ok(attendance.update(id,r)); }
 @GetMapping("/students/{id}/attendance") public ApiResponse<List<AttendanceResponse>> history(@PathVariable Long id) { return ApiResponse.ok(attendance.history(id)); }
 @GetMapping("/students/{id}/attendance/summary") public ApiResponse<AttendanceSummary> summary(@PathVariable Long id) { return ApiResponse.ok(attendance.summary(id)); }
}

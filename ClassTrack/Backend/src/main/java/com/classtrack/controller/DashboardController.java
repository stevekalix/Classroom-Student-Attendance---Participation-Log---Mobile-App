package com.classtrack.controller;
import com.classtrack.service.DashboardService;
import com.classtrack.dto.response.*;
import com.classtrack.util.DateUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
@RestController @RequestMapping("/api/v1/dashboard") @RequiredArgsConstructor
public class DashboardController {
 private final DashboardService dashboard;
 @GetMapping public ApiResponse<DashboardResponse> get(@RequestParam(required=false) LocalDate date) { return ApiResponse.ok(dashboard.summary(date==null?DateUtils.today():date)); }
}

package com.classtrack.controller;
import com.classtrack.service.AuthService;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
@RestController @RequestMapping("/api/v1/auth") @RequiredArgsConstructor
public class AuthController {
 private final AuthService auth;
 @PostMapping("/register") @ResponseStatus(HttpStatus.CREATED) public ApiResponse<AuthResponse> register(@Valid @RequestBody RegisterRequest r) { return ApiResponse.ok(auth.register(r)); }
 @PostMapping("/login") public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest r) { return ApiResponse.ok(auth.login(r)); }
 @GetMapping("/me") public ApiResponse<TeacherResponse> me() { return ApiResponse.ok(auth.me()); }
}

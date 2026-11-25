package com.classtrack.service.impl;
import com.classtrack.service.AuthService;
import com.classtrack.repository.TeacherRepository;
import com.classtrack.entity.Teacher;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import com.classtrack.exception.*;
import com.classtrack.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import java.util.Locale;
@Service @RequiredArgsConstructor @Transactional
public class AuthServiceImpl implements AuthService {
 private final TeacherRepository teachers; private final PasswordEncoder encoder; private final JwtService jwt;
 public AuthResponse register(RegisterRequest r) {
 String email=r.email().strip().toLowerCase(Locale.ROOT);
 if(teachers.existsByEmail(email)) throw new ApiException(409,"EMAIL_EXISTS","Email already registered");
 if(r.password().getBytes(java.nio.charset.StandardCharsets.UTF_8).length>72) throw new ApiException(400,"PASSWORD_TOO_LONG","Password must not exceed 72 UTF-8 bytes");
 Teacher t=new Teacher();t.setEmail(email);t.setFullName(r.fullName().strip());t.setPasswordHash(encoder.encode(r.password()));teachers.saveAndFlush(t);return response(t);
 }
 public AuthResponse login(LoginRequest r) {
 if(r.password().getBytes(java.nio.charset.StandardCharsets.UTF_8).length>72) throw new UnauthorizedException("Invalid email or password");
 Teacher t=teachers.findByEmail(r.email().strip().toLowerCase(Locale.ROOT)).orElse(null);
 String hash=t==null?"$2a$12$k8Xr6JKr5ZrEIlYof5rYCe6caL4u9s2xQ4uoA8RLGjQCZ/Y.sxjza":t.getPasswordHash();
 if(!encoder.matches(r.password(),hash) || t==null) throw new UnauthorizedException("Invalid email or password");return response(t);
 }
 public Teacher current() { var auth=SecurityContextHolder.getContext().getAuthentication(); if(auth==null) throw new UnauthorizedException("Authentication required");return teachers.findByEmail(auth.getName()).orElseThrow(()->new UnauthorizedException("Account unavailable")); }
 public TeacherResponse me() { return teacher(current()); }
 private TeacherResponse teacher(Teacher t) { return new TeacherResponse(t.getId(),t.getFullName(),t.getEmail()); }
 private AuthResponse response(Teacher t) { return new AuthResponse(jwt.issue(t.getEmail()),"Bearer",jwt.expirationSeconds(),teacher(t)); }
}

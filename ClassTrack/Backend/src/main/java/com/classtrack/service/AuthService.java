package com.classtrack.service;
import com.classtrack.dto.request.*;
import com.classtrack.dto.response.*;
import com.classtrack.entity.Teacher;
public interface AuthService { AuthResponse register(RegisterRequest r); AuthResponse login(LoginRequest r); Teacher current(); TeacherResponse me(); }

package com.classtrack.dto.response;
public record AuthResponse(String token, String tokenType, long expiresIn, TeacherResponse teacher) {}

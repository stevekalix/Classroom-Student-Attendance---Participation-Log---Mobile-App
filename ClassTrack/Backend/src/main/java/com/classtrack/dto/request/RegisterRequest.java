package com.classtrack.dto.request;
import jakarta.validation.constraints.*;
public record RegisterRequest(@NotBlank @Size(max=150) String fullName, @NotBlank @Email @Size(max=254) String email, @NotBlank @Size(min=10,max=72) @Pattern(regexp="^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).+$", message="Password must include upper, lower case and a number") String password) {}

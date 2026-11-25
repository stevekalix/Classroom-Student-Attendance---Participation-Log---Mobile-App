package com.classtrack.security;
import com.classtrack.repository.TeacherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;
@Service @RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {
 private final TeacherRepository teachers;
 public UserDetails loadUserByUsername(String email) { var t=teachers.findByEmail(email).orElseThrow(()->new UsernameNotFoundException("Unknown account")); return User.withUsername(t.getEmail()).password(t.getPasswordHash()).roles(t.getRole().name()).build(); }
}

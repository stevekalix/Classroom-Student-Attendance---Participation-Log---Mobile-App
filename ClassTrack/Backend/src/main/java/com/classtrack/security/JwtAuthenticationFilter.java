package com.classtrack.security;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
@Component @RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
 private final JwtService jwt; private final CustomUserDetailsService users;
 protected void doFilterInternal(HttpServletRequest req,HttpServletResponse res,FilterChain chain) throws ServletException,IOException {
 String header=req.getHeader("Authorization");
 if(header!=null && header.startsWith("Bearer ")) {
 try { var user=users.loadUserByUsername(jwt.subject(header.substring(7))); SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(user,null,user.getAuthorities())); }
 catch(io.jsonwebtoken.JwtException | IllegalArgumentException | org.springframework.security.core.userdetails.UsernameNotFoundException e) { SecurityContextHolder.clearContext(); res.setStatus(401);res.setContentType("application/json");res.getWriter().write("{\"success\":false,\"message\":\"Session expired or invalid\",\"code\":\"UNAUTHORIZED\"}");return; }
 }
 chain.doFilter(req,res);
 }
}

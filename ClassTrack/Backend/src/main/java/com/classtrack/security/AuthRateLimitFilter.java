package com.classtrack.security;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
@Component
public class AuthRateLimitFilter extends OncePerRequestFilter {
 private record Window(long start,int count) {}
 private final ConcurrentHashMap<String,Window> windows=new ConcurrentHashMap<>();
 protected void doFilterInternal(HttpServletRequest req,HttpServletResponse res,FilterChain chain) throws ServletException,IOException {
 if(req.getMethod().equals("POST") && (req.getRequestURI().equals("/api/v1/auth/login") || req.getRequestURI().equals("/api/v1/auth/register"))) {
 long now=System.currentTimeMillis();
 windows.entrySet().removeIf(e->now-e.getValue().start()>60000);
 if(windows.size()>10000) { res.sendError(429); return; }
 Window w=windows.compute(req.getRemoteAddr(),(k,old)->old==null || now-old.start()>60000 ? new Window(now,1):new Window(old.start(),old.count()+1));
 if(w.count()>20) { res.setStatus(429);res.setHeader("Retry-After","60");res.setContentType("application/json");res.getWriter().write("{\"success\":false,\"message\":\"Too many attempts. Try again in a minute.\",\"code\":\"RATE_LIMITED\"}");return; }
 }
 chain.doFilter(req,res);
 }
}

package com.classtrack.security;
import org.springframework.context.annotation.*;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
@Configuration
public class SecurityConfig {
 @Bean PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(12); }
 @Bean FilterRegistrationBean<JwtAuthenticationFilter> jwtRegistration(JwtAuthenticationFilter f) { var r=new FilterRegistrationBean<>(f);r.setEnabled(false);return r; }
 @Bean FilterRegistrationBean<AuthRateLimitFilter> rateRegistration(AuthRateLimitFilter f) { var r=new FilterRegistrationBean<>(f);r.setEnabled(false);return r; }
 @Bean SecurityFilterChain security(HttpSecurity http,JwtAuthenticationFilter jwt,AuthRateLimitFilter rate) throws Exception {
 return http.csrf(c->c.disable()).sessionManagement(s->s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
 .authorizeHttpRequests(a->a.requestMatchers("/api/v1/auth/login","/api/v1/auth/register","/actuator/health").permitAll().anyRequest().authenticated())
 .exceptionHandling(e->e.authenticationEntryPoint((req,res,ex)->{res.setStatus(401);res.setContentType("application/json");res.getWriter().write("{\"success\":false,\"message\":\"Authentication required\",\"code\":\"UNAUTHORIZED\"}");}))
 .addFilterBefore(jwt,UsernamePasswordAuthenticationFilter.class).addFilterBefore(rate,JwtAuthenticationFilter.class).build();
 }
}

package com.classtrack.security;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
@Service
public class JwtService {
 private final SecretKey key; private final long expiration;
 public JwtService(@Value("${app.jwt.secret}") String secret,@Value("${app.jwt.expiration-seconds}") long expiration) {
 if(secret.getBytes(StandardCharsets.UTF_8).length<32) throw new IllegalArgumentException("JWT_SECRET must be at least 32 bytes");
 key=Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8)); this.expiration=expiration;
 }
 public long expirationSeconds() { return expiration; }
 public String issue(String email) { Instant now=Instant.now(); return Jwts.builder().issuer("classtrack").subject(email).issuedAt(Date.from(now)).expiration(Date.from(now.plusSeconds(expiration))).signWith(key).compact(); }
 public String subject(String token) { return Jwts.parser().verifyWith(key).requireIssuer("classtrack").build().parseSignedClaims(token).getPayload().getSubject(); }
}

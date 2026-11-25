package com.classtrack.exception;
import com.classtrack.dto.response.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.security.access.AccessDeniedException;
@RestControllerAdvice
public class GlobalExceptionHandler {
 @ExceptionHandler(ApiException.class) ResponseEntity<?> api(ApiException e) { return ResponseEntity.status(e.getStatus()).body(ApiResponse.error(e.getMessage(),e.getCode())); }
 @ExceptionHandler(MethodArgumentNotValidException.class) ResponseEntity<?> validation(MethodArgumentNotValidException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getBindingResult().getFieldErrors().stream().map(f->f.getField()+": "+f.getDefaultMessage()).sorted().findFirst().orElse("Invalid request"),"VALIDATION_ERROR")); }
 @ExceptionHandler({IllegalArgumentException.class,HttpMessageNotReadableException.class,MethodArgumentTypeMismatchException.class}) ResponseEntity<?> bad(Exception e) { return ResponseEntity.badRequest().body(ApiResponse.error("Invalid request parameters or body","BAD_REQUEST")); }
 @ExceptionHandler(DataIntegrityViolationException.class) ResponseEntity<?> conflict(Exception e) { return ResponseEntity.status(409).body(ApiResponse.error("A record with these unique values already exists","CONFLICT")); }
 @ExceptionHandler(AccessDeniedException.class) ResponseEntity<?> forbidden(Exception e) { return ResponseEntity.status(403).body(ApiResponse.error("Access denied","FORBIDDEN")); }
 @ExceptionHandler(Exception.class) ResponseEntity<?> unexpected(Exception e) { return ResponseEntity.internalServerError().body(ApiResponse.error("An unexpected error occurred","INTERNAL_ERROR")); }
}

package com.classtrack;
import org.junit.jupiter.api.Test;
import com.classtrack.service.*;
import com.classtrack.service.impl.*;
import com.classtrack.repository.*;
import com.classtrack.dto.request.*;
import com.classtrack.entity.*;
import com.classtrack.exception.*;
import com.classtrack.enums.AttendanceStatus;
import com.classtrack.util.DateUtils;
import com.classtrack.security.JwtService;
import java.time.LocalDate;
import java.util.*;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;
class ServiceUnitTest {
 @Test void percentageExcludesUnmarkedAndHandlesZero() { assertEquals(0,DateUtils.percentage(0,0,0));assertEquals(89.58,DateUtils.percentage(40,3,48)); }
 @Test void invalidJwtAndShortSecretsFail() { assertThrows(IllegalArgumentException.class,()->new JwtService("short",3600));var jwt=new JwtService("unit-test-signing-secret-at-least-32-bytes",3600);assertEquals("t@example.com",jwt.subject(jwt.issue("t@example.com")));assertThrows(io.jsonwebtoken.JwtException.class,()->jwt.subject("tampered.token.data")); }
 @Test void duplicateBatchIsRejectedBeforeWriting() {
 var repo=mock(AttendanceRepository.class);var svc=new AttendanceServiceImpl(repo,mock(StudentService.class),mock(AuthService.class));
 var row=new AttendanceRequest(1L,LocalDate.now(),AttendanceStatus.PRESENT);
 assertThrows(ApiException.class,()->svc.bulk(new BulkAttendanceRequest(List.of(row,row))));verifyNoInteractions(repo);
 }
 @Test void foreignStudentIsNotExposed() {
 var repo=mock(StudentRepository.class);var auth=mock(AuthService.class);var teacher=new Teacher();teacher.setId(2L);when(auth.current()).thenReturn(teacher);when(repo.findByIdAndTeacherId(1L,2L)).thenReturn(Optional.empty());
 var svc=new StudentServiceImpl(repo,mock(AttendanceRepository.class),auth);assertThrows(ResourceNotFoundException.class,()->svc.owned(1L));
 }
}
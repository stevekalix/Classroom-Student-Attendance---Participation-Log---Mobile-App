package com.classtrack;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.mysql.MySQLContainer;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import java.util.UUID;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.junit.jupiter.api.Assertions.*;
@SpringBootTest @AutoConfigureMockMvc
class ApiIntegrationTest {
 static MySQLContainer mysql;
 @DynamicPropertySource static void config(DynamicPropertyRegistry r) {
 String url=System.getenv("TEST_DB_URL");
 if(url==null) { mysql=new MySQLContainer("mysql:8.0.42");mysql.start();r.add("spring.datasource.url",mysql::getJdbcUrl);r.add("spring.datasource.username",mysql::getUsername);r.add("spring.datasource.password",mysql::getPassword); }
 else {
 if(!url.matches("jdbc:mysql://[^/]+/classtrack_test_[a-zA-Z0-9_]+(\\?.*)?")) throw new IllegalArgumentException("Only isolated classtrack_test_* schemas are allowed");
 r.add("spring.datasource.url",()->url);r.add("spring.datasource.username",()->System.getenv().getOrDefault("TEST_DB_USERNAME","root"));r.add("spring.datasource.password",()->System.getenv().getOrDefault("TEST_DB_PASSWORD","root123"));
 }
 r.add("springdoc.api-docs.enabled",()->true);
 r.add("app.jwt.secret",()->"isolated-test-signing-secret-32-bytes-minimum");
 }
 @Autowired MockMvc mvc;
 @Autowired ObjectMapper json;
 private JsonNode call(String method,String path,String token,String body,int expected) throws Exception {
 var request=switch(method) { case "POST"->post(path);case "PATCH"->patch(path);case "DELETE"->delete(path);default->get(path); };
 if(token!=null)request.header("Authorization","Bearer "+token);
 if(body!=null)request.contentType("application/json").content(body);
 var result=mvc.perform(request).andExpect(status().is(expected)).andReturn().getResponse().getContentAsString();
 return result.isBlank()?json.createObjectNode():json.readTree(result);
 }
 private String register(String suffix) throws Exception {
 return call("POST","/api/v1/auth/register",null,"{\"fullName\":\"Teacher\",\"email\":\""+suffix+"@example.com\",\"password\":\"TestPassword123!\"}",201).path("data").path("token").asString();
 }
 private String student(String roll,String name) { return "{\"fullName\":\""+name+"\",\"rollId\":\""+roll+"\",\"className\":\"Year 3\",\"subjectGroup\":\"CSE\",\"enrollmentDate\":\"2026-01-01\",\"academicNotes\":\"Progressing well\"}"; }
 private String mark(long id,String day,String status) { return "{\"studentId\":"+id+",\"attendanceDate\":\""+day+"\",\"status\":\""+status+"\"}"; }
 @Test void completeTeacherWorkflowAndIsolation() throws Exception {
 String name=UUID.randomUUID().toString(),token=register(name),other=register(UUID.randomUUID().toString());
 call("GET","/api/v1/auth/me",token,null,200);
 assertTrue(call("GET","/v3/api-docs",token,null,200).has("openapi"));
 call("POST","/api/v1/auth/login",null,"{\"email\":\""+name+"@example.com\",\"password\":\"TestPassword123!\"}",200);
 call("POST","/api/v1/auth/login",null,"{\"email\":\""+name+"@example.com\",\"password\":\"incorrect\"}",401);
 long id=call("POST","/api/v1/students",token,student("CSE001","Arun Kumar"),201).path("data").path("id").asLong();
 call("POST","/api/v1/students",token,student("CSE001","Duplicate"),409);
 call("GET","/api/v1/students/"+id,token,null,200);
 call("PATCH","/api/v1/students/"+id,token,student("CSE001","Arun Updated"),200);
 assertEquals(1,call("GET","/api/v1/students?search=arun&subjectGroup=CSE",token,null,200).path("data").path("totalElements").asInt());
 call("GET","/api/v1/students/"+id,other,null,404);
 call("PATCH","/api/v1/students/"+id,other,student("X","Intruder"),404);
 call("DELETE","/api/v1/students/"+id,other,null,404);
 call("POST","/api/v1/attendance",other,mark(id,"2026-11-25","PRESENT"),404);
 call("POST","/api/v1/attendance",token,mark(id,"2025-01-01","PRESENT"),422);
 long attendanceId=call("POST","/api/v1/attendance",token,mark(id,"2026-11-25","PRESENT"),200).path("data").path("id").asLong();
 assertEquals(attendanceId,call("POST","/api/v1/attendance",token,mark(id,"2026-11-25","LATE"),200).path("data").path("id").asLong());
 call("PATCH","/api/v1/attendance/"+attendanceId,other,mark(id,"2026-11-25","ABSENT"),404);
 call("PATCH","/api/v1/attendance/"+attendanceId,token,mark(id,"2026-11-25","PRESENT"),200);
 call("POST","/api/v1/attendance/bulk",token,"{\"records\":["+mark(id,"2026-11-24","ABSENT")+","+mark(id,"2026-11-23","LATE")+"]}",200);
 var summary=call("GET","/api/v1/students/"+id+"/attendance/summary",token,null,200).path("data");assertEquals(3,summary.path("totalDays").asInt());assertEquals(66.67,summary.path("attendancePercentage").asDouble(),0.01);
 call("POST","/api/v1/attendance/bulk",token,"{\"records\":["+mark(id,"2026-11-22","PRESENT")+","+mark(999999999,"2026-11-22","PRESENT")+"]}",404);
 assertEquals(3,call("GET","/api/v1/students/"+id+"/attendance",token,null,200).path("data").size(),"Bulk failure must roll back earlier writes");
 long unmarked=call("POST","/api/v1/students",token,student("CSE002","Unmarked"),201).path("data").path("id").asLong();assertTrue(unmarked>0);
 var dashboard=call("GET","/api/v1/dashboard?date=2026-11-25",token,null,200).path("data");assertEquals(2,dashboard.path("totalStudents").asInt());assertEquals(1,dashboard.path("unmarkedCount").asInt());assertEquals(100,dashboard.path("attendancePercentage").asDouble());
 assertEquals(1,call("GET","/api/v1/students?status=UNMARKED&date=2026-11-25",token,null,200).path("data").path("totalElements").asInt());
 String note="{\"category\":\"PARTICIPATION\",\"content\":\"Led a class discussion\"}";
 long noteId=call("POST","/api/v1/students/"+id+"/notes",token,note,201).path("data").path("id").asLong();
 call("GET","/api/v1/students/"+id+"/notes",other,null,404);
 call("PATCH","/api/v1/notes/"+noteId,other,note,404);
 call("DELETE","/api/v1/notes/"+noteId,other,null,404);
 call("PATCH","/api/v1/notes/"+noteId,token,"{\"category\":\"ACADEMIC_PROGRESS\",\"content\":\"Improved this week\"}",200);
 assertEquals(1,call("GET","/api/v1/students/"+id+"/notes",token,null,200).path("data").size());
 call("DELETE","/api/v1/students/"+id,token,null,204);
 assertEquals(1,call("GET","/api/v1/students",token,null,200).path("data").path("totalElements").asInt());
 assertEquals(3,call("GET","/api/v1/students/"+id+"/attendance",token,null,200).path("data").size());
 assertEquals(1,call("GET","/api/v1/students/"+id+"/notes",token,null,200).path("data").size());
 call("DELETE","/api/v1/notes/"+noteId,token,null,204);
 assertEquals(0,call("GET","/api/v1/students/"+id+"/notes",token,null,200).path("data").size());
 }
 @Test void protectsEndpointsAndRejectsInvalidInput() throws Exception {
 call("GET","/api/v1/students",null,null,401);call("GET","/api/v1/dashboard",null,null,401);call("GET","/actuator/health",null,null,200);call("GET","/swagger-ui/index.html",null,null,401);
 call("POST","/api/v1/auth/register",null,"{\"fullName\":\"\",\"email\":\"bad\",\"password\":\"weak\"}",400);
 String token=register(UUID.randomUUID().toString());
 call("GET","/api/v1/students?size=1000",token,null,400);call("GET","/api/v1/students?status=INVALID",token,null,400);call("GET","/api/v1/attendance?date=bad",token,null,400);
 String expired=new com.classtrack.security.JwtService("isolated-test-signing-secret-32-bytes-minimum",-1).issue("nobody@example.com");
 call("GET","/api/v1/students",expired,null,401);
 assertEquals(0,call("GET","/api/v1/dashboard",token,null,200).path("data").path("attendancePercentage").asDouble());
 }
}
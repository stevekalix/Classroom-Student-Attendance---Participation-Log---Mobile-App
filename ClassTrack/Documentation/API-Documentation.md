# REST API

Base URL: `http://127.0.0.1:8080/api/v1` locally. Production must use HTTPS. JSON property names are camelCase. Identifiers are 64-bit integers. Dates are `yyyy-MM-dd`; timestamps are UTC ISO-8601 strings.

Send `Authorization: Bearer <token>` except on registration, login and `/actuator/health`. Teacher IDs in payloads are never used to determine ownership.

## Envelopes

Success: `{"success":true,"message":"Success","data":{...},"code":null}`.

Failure: `{"success":false,"message":"Roll ID already exists","data":null,"code":"DUPLICATE_ROLL_ID"}`.

DELETE returns 204 with no body. Lists of attendance/notes are arrays in `data`. Student lists use `data: {content: [...], number: 0, totalPages: 1, totalElements: 12}`.

## Routes

| Method | Path | Input | Result |
|---|---|---|---|
| POST | `/auth/register` | fullName, email, password | 201 AuthResponse |
| POST | `/auth/login` | email, password | 200 AuthResponse |
| GET | `/auth/me` | none | Teacher |
| GET | `/students` | query parameters below | paginated Students |
| POST | `/students` | StudentRequest | 201 Student |
| GET | `/students/{id}` | owned ID | Student |
| PATCH | `/students/{id}` | complete StudentRequest | updated Student |
| DELETE | `/students/{id}` | owned ID | 204; soft deletion |
| GET | `/attendance?date=YYYY-MM-DD` | required date | active roster's saved marks |
| POST | `/attendance` | AttendanceRequest | 200 upserted Attendance |
| POST | `/attendance/bulk` | `{records:[AttendanceRequest,...]}` | 200 updated marks; atomic |
| PATCH | `/attendance/{id}` | AttendanceRequest | 200; student/date must match original |
| GET | `/students/{id}/attendance` | owned student | history, newest date first |
| GET | `/students/{id}/attendance/summary` | owned student | AttendanceSummary |
| GET | `/students/{id}/notes` | owned student | notes, most recently updated first |
| POST | `/students/{id}/notes` | NoteRequest | 201 Note |
| PATCH | `/notes/{id}` | complete NoteRequest | updated Note |
| DELETE | `/notes/{id}` | owned note | 204 |
| GET | `/dashboard?date=YYYY-MM-DD` | optional date, UTC today default | DashboardSummary |

Outside API base: `GET /actuator/health`, public, minimal status only.

### Authentication

```json
{"fullName":"Sample Teacher","email":"teacher@example.com","password":"ExamplePassword123!"}
```

Passwords require 10+ characters, uppercase, lowercase and a digit, and at most 72 UTF-8 bytes. Login omits fullName. AuthResponse contains token, tokenType (`Bearer`), expiresIn (seconds), and teacher `{id,fullName,email}`. Email is unique. Password hashes never leave the backend. Registration/login have a limit of 20 requests per IP/minute; excess calls return 429 and Retry-After.

### Student request

```json
{"fullName":"Arun Kumar","rollId":"CSE001","className":"Third Year","subjectGroup":"Computer Science","enrollmentDate":"2026-11-25","academicNotes":"Good academic performance"}
```

PATCH currently expects all required student fields; it replaces this editable form, not an arbitrary JSON Merge Patch. Maximum lengths: fullName 150, rollId 50, className/subjectGroup 100, academicNotes 10,000. Student response adds id, isActive, attendanceStatus. `attendanceStatus` is PRESENT, ABSENT, LATE or UNMARKED.

Student query parameters:

| Parameter | Default | Meaning |
|---|---|---|
| search | empty | case-insensitive substring of name or roll ID; literal wildcard characters escaped |
| className | empty | case-insensitive exact match |
| subjectGroup | empty | case-insensitive exact match |
| status | omitted | PRESENT, ABSENT, LATE, UNMARKED |
| date | UTC today | day for attendance status/filter |
| active | true | false lists archived students |
| page | 0 | zero-based page |
| size | 20 | 1–100 |
| sort | fullName | fullName, rollId, enrollmentDate, createdAt; ascending with ID tiebreaker |

Combine parameters freely, e.g. `/students?search=kumar&subjectGroup=Computer%20Science&status=PRESENT&date=2026-11-25&page=0&size=20`.

### Attendance

```json
{"studentId":1,"attendanceDate":"2026-11-25","status":"PRESENT"}
```

Only PRESENT/ABSENT/LATE can be saved. No record means UNMARKED. AttendanceResponse contains id, studentId, attendanceDate, status. Bulk saves accept 1–500 distinct student/date pairs. Changing status for an existing date reuses its ID. Invalid ownership/date or any write failure rolls back the batch. Concurrent conflicting inserts return 409; retry to upsert after the winning transaction commits.

AttendanceSummary: totalDays, presentDays, absentDays, lateDays, attendancePercentage. Percentage rounds to two decimals and returns zero without marked days. `(presentDays + lateDays) / totalDays × 100`.

### Notes

```json
{"category":"PARTICIPATION","content":"Led the class discussion today."}
```

Categories: ACADEMIC_PROGRESS, PARTICIPATION, BEHAVIOR, GENERAL. Nonblank content up to 10,000 characters. Response: id, studentId, teacherId, category, content, createdAt, updatedAt. Timestamps are generated by the backend, not the client.

### Dashboard

Returns totalStudents, presentCount, absentCount, lateCount, unmarkedCount, attendancePercentage, recentStudents (up to 5) and recentNotes (up to 5). Only active students count. Unmarked = active students minus saved marks for the requested day; it is never treated as absent. Percentage denominator is marked students.

## Errors

400 malformed/invalid input; 401 missing/invalid/expired JWT or wrong credentials; 403 denied authorization; 404 missing or foreign-owned resource; 409 uniqueness conflict; 422 attendance before enrollment or marking an inactive student; 429 authentication limit; 500 sanitized internal error. No stack traces, passwords or signing secrets are returned. Clients should preserve input after errors and offer retry; 401 requires manual login or a still-valid biometric session.

## Swagger

Dev profile: `/swagger-ui/index.html` and `/v3/api-docs`, protected by bearer authentication. See [backend instructions](../Backend/README.md). Production profile disables both.

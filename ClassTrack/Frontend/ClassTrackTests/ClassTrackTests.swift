import XCTest
@testable import ClassTrack
@MainActor final class ClassTrackTests: XCTestCase {
 func testInvalidCredentialsPreserveSessionCallbackAndServerMessage() async throws {
 let configuration = URLSessionConfiguration.ephemeral
 configuration.protocolClasses = [StubURLProtocol.self]
 let api = APIClient(session: URLSession(configuration: configuration), baseURL: URL(string: "https://example.com/api/v1")!)
 var expired = false
 api.onUnauthorized = { expired = true }
 StubURLProtocol.status = 401
 StubURLProtocol.data = Data(#"{"success":false,"message":"Invalid email or password","data":null,"code":"UNAUTHORIZED"}"#.utf8)
 do {
 let _: AuthResponse = try await api.request("auth/login", method: .post)
 XCTFail("Expected invalid credentials")
 } catch {
 XCTAssertEqual(error.localizedDescription, "Invalid email or password")
 }
 XCTAssertFalse(expired, "A failed login is not an expired existing session")
 }

 func testHistoryEditUsesPatchAndPreservesSavedStateOnFailure() async throws {
 let configuration = URLSessionConfiguration.ephemeral
 configuration.protocolClasses = [StubURLProtocol.self]
 let api = APIClient(session: URLSession(configuration: configuration), baseURL: URL(string: "https://example.com/api/v1")!)
 api.token = "test-token"
 let service = AttendanceService(api: api)
 let vm = StudentDetailViewModel(attendance: service)
 let record = Attendance(id: 19, studentId: 7, attendanceDate: "2026-11-25", status: .absent)
 vm.history = [record]
 StubURLProtocol.status = 409
 StubURLProtocol.data = Data(#"{"success":false,"message":"Conflict; retry","data":null,"code":"CONFLICT"}"#.utf8)
 await vm.updateAttendance(record, status: .late)
 XCTAssertEqual(vm.history.first?.status, .absent)
 XCTAssertEqual(vm.error, "Conflict; retry")
 XCTAssertFalse(vm.isSavingAttendance)
 StubURLProtocol.status = 200
 StubURLProtocol.data = Data(#"{"success":true,"data":{"id":19,"studentId":7,"attendanceDate":"2026-11-25","status":"LATE"}}"#.utf8)
 await vm.updateAttendance(record, status: .late)
 XCTAssertEqual(vm.history.first?.status, .late)
 XCTAssertNil(vm.error)
 XCTAssertNotNil(vm.attendanceMessage)
 let request = try XCTUnwrap(StubURLProtocol.lastRequest)
 XCTAssertEqual(request.httpMethod, "PATCH")
 XCTAssertEqual(request.url?.path, "/api/v1/attendance/19")
 XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
 XCTAssertFalse(vm.isSavingAttendance)
 }

 func testValidation() {
 XCTAssertTrue(Validators.email("teacher@example.com")); XCTAssertFalse(Validators.email("bad"))
 XCTAssertFalse(Validators.password("short")); XCTAssertTrue(Validators.password("Password123!"))
 XCTAssertFalse(Validators.password(String(repeating: "Ab1", count: 30)))
 var form = StudentForm(); XCTAssertNotNil(form.validationError)
 form.fullName = "Arun"; form.rollId = "CS1"; form.className = "Year 3"; XCTAssertNil(form.validationError)
 }
 func testCodableContractAndInt64Identifiers() throws {
 let data = Data(#"{"id":9007199254740991,"fullName":"Arun","rollId":"CS1","className":"Year 3","subjectGroup":"CSE","enrollmentDate":"2026-11-25","academicNotes":null,"isActive":true,"attendanceStatus":"UNMARKED"}"#.utf8)
 let student = try JSONDecoder().decode(Student.self, from: data)
 XCTAssertEqual(student.id, 9007199254740991); XCTAssertEqual(student.attendanceStatus, .unmarked)
 let request = AttendanceRequest(studentId: student.id, attendanceDate: "2026-11-25", status: .present)
 let object = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any])
 XCTAssertEqual(object["status"] as? String, "PRESENT")
 }
 func testAttendanceMathAndFilterQuery() {
 XCTAssertEqual(AttendanceSummary.percentage(present: 0, late: 0, total: 0), 0)
 XCTAssertEqual(AttendanceSummary.percentage(present: 40, late: 3, total: 48), 89.5833, accuracy: 0.001)
 var filter = StudentFilter(); filter.status = .unmarked; filter.subjectGroup = "CSE"
 let query = filter.query(search: "Kumar", page: 2)
 XCTAssertTrue(query.contains(URLQueryItem(name: "status", value: "UNMARKED")))
 XCTAssertTrue(query.contains(URLQueryItem(name: "search", value: "Kumar")))
 XCTAssertTrue(query.contains(URLQueryItem(name: "page", value: "2")))
 }
 func testInvalidLoginAndRegistrationNeverReachAPI() async {
 let service = MockAuthService(); let vm = AuthViewModel(service: service, api: APIClient(baseURL: URL(string: "https://example.com/api/v1")!))
 await vm.authenticate(email: "bad", password: "x")
 XCTAssertNotNil(vm.error); XCTAssertFalse(vm.isLoading); XCTAssertNil(vm.teacher)
 await vm.authenticate(name: "Teacher", email: "t@example.com", password: "Password123!", confirmation: "different", register: true)
 XCTAssertEqual(service.calls, 0); XCTAssertNotNil(vm.error)
 }
 func testDashboardLoadingErrorAndRecovery() async {
 let service = MockDashboardService(); let vm = DashboardViewModel(service: service)
 await vm.load(); XCTAssertFalse(vm.isLoading); XCTAssertNotNil(vm.error); XCTAssertNil(vm.summary)
 service.shouldFail = false; await vm.load(); XCTAssertNil(vm.error); XCTAssertEqual(vm.summary?.totalStudents, 0)
 }
 func testAPIUnauthorizedAndEmptyDelete() async throws {
 let configuration = URLSessionConfiguration.ephemeral; configuration.protocolClasses = [StubURLProtocol.self]
 let api = APIClient(session: URLSession(configuration: configuration), baseURL: URL(string: "https://example.com/api/v1")!)
 var expired = false; api.onUnauthorized = { expired = true }
 StubURLProtocol.status = 401; StubURLProtocol.data = Data()
 do { let _: Teacher = try await api.request("auth/me"); XCTFail("Expected unauthorized") } catch { XCTAssertTrue(error is APIError) }
 XCTAssertTrue(expired)
 StubURLProtocol.status = 204
 let _: EmptyResponse = try await api.request("students/1", method: .delete)
 StubURLProtocol.status = 200; StubURLProtocol.data = Data("not json".utf8)
 do { let _: Teacher = try await api.request("auth/me"); XCTFail("Expected decoding failure") } catch { XCTAssertEqual(error.localizedDescription, APIError.decoding.localizedDescription) }
 }
}
@MainActor private final class MockAuthService: AuthServiceProtocol {
 var calls = 0
 func login(email: String, password: String) async throws -> AuthResponse { calls += 1; throw APIError.unauthorized }
 func register(name: String, email: String, password: String) async throws -> AuthResponse { calls += 1; throw APIError.unauthorized }
 func me() async throws -> Teacher { throw APIError.unauthorized }
}
@MainActor private final class MockDashboardService: DashboardServiceProtocol {
 var shouldFail = true
 func summary() async throws -> DashboardSummary {
 if shouldFail { throw APIError.network("Offline") }
 return DashboardSummary(totalStudents: 0, presentCount: 0, absentCount: 0, lateCount: 0, unmarkedCount: 0, attendancePercentage: 0, recentStudents: [], recentNotes: [])
 }
}
private final class StubURLProtocol: URLProtocol {
 static var lastRequest: URLRequest?
 static var status = 200
 static var data = Data()
 override class func canInit(with request: URLRequest) -> Bool { true }
 override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
 override func startLoading() {
 Self.lastRequest = request
 let response = HTTPURLResponse(url: request.url!, statusCode: Self.status, httpVersion: nil, headerFields: nil)!
 client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
 client?.urlProtocol(self, didLoad: Self.data); client?.urlProtocolDidFinishLoading(self)
 }
 override func stopLoading() {}
}

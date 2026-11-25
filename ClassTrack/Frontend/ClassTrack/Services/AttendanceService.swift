import Foundation
@MainActor protocol AttendanceServiceProtocol {
 func daily(_ date: Date) async throws -> [Attendance]
 func save(_ records: [AttendanceRequest]) async throws -> [Attendance]
 func update(_ record: Attendance, status: AttendanceStatus) async throws -> Attendance
 func history(_ id: Int64) async throws -> [Attendance]
 func summary(_ id: Int64) async throws -> AttendanceSummary
}
@MainActor final class AttendanceService: AttendanceServiceProtocol {
 private let api: any APIClientProtocol
 init(api: (any APIClientProtocol)? = nil) { self.api = api ?? APIClient.shared }
 func daily(_ date: Date) async throws -> [Attendance] { try await api.request("attendance", method: .get, query: [URLQueryItem(name: "date", value: DateHelper.string(date))], body: nil) }
 func save(_ records: [AttendanceRequest]) async throws -> [Attendance] { try await api.request("attendance/bulk", method: .post, query: [], body: JSONEncoder().encode(BulkAttendanceRequest(records: records))) }
 func update(_ record: Attendance, status: AttendanceStatus) async throws -> Attendance {
 guard status != .unmarked else { throw APIError.server(400, "Saved attendance must be Present, Absent or Late.") }
 let body = AttendanceRequest(studentId: record.studentId, attendanceDate: record.attendanceDate, status: status)
 return try await api.request("attendance/\(record.id)", method: .patch, query: [], body: JSONEncoder().encode(body))
 }
 func history(_ id: Int64) async throws -> [Attendance] { try await api.request("students/\(id)/attendance", method: .get, query: [], body: nil) }
 func summary(_ id: Int64) async throws -> AttendanceSummary { try await api.request("students/\(id)/attendance/summary", method: .get, query: [], body: nil) }
}

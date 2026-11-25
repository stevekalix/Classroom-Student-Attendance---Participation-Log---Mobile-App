import Foundation
struct AttendanceRequest: Encodable { let studentId: Int64; let attendanceDate: String; let status: AttendanceStatus }
struct BulkAttendanceRequest: Encodable { let records: [AttendanceRequest] }

import Foundation
struct Attendance: Codable, Identifiable { let id, studentId: Int64; let attendanceDate: String; let status: AttendanceStatus }
struct AttendanceSummary: Codable {
 let totalDays, presentDays, absentDays, lateDays: Int64
 let attendancePercentage: Double
 static func percentage(present: Int, late: Int, total: Int) -> Double { total == 0 ? 0 : Double(present + late) / Double(total) * 100 }
}

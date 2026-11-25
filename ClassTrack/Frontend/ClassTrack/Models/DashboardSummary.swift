import Foundation
struct DashboardSummary: Decodable {
 let totalStudents, presentCount, absentCount, lateCount, unmarkedCount: Int64
 let attendancePercentage: Double
 let recentStudents: [Student]
 let recentNotes: [ProgressNote]
}

import Foundation
struct AttendanceSlice: Identifiable { let status: AttendanceStatus; let count: Int64; var id: String { status.rawValue } }

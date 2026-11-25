import Foundation
import Combine
@MainActor final class StudentDetailViewModel: ObservableObject {
 @Published var student: Student?
 @Published var summary: AttendanceSummary?
 @Published var history: [Attendance] = []
 @Published var isLoading = false
 @Published var isSavingAttendance = false
 @Published var attendanceMessage: String?
 @Published var error: String?
 private let students: any StudentServiceProtocol
 private let attendance: any AttendanceServiceProtocol
 init(students: (any StudentServiceProtocol)? = nil, attendance: (any AttendanceServiceProtocol)? = nil) { self.students = students ?? StudentService(); self.attendance = attendance ?? AttendanceService() }
 func load(_ id: Int64) async {
 guard !isLoading else { return }; isLoading = true; error = nil; defer { isLoading = false }
 do { student = try await students.get(id); summary = try await attendance.summary(id); history = try await attendance.history(id) } catch is CancellationError {} catch { self.error = error.localizedDescription }
 }
 func updateAttendance(_ record: Attendance, status: AttendanceStatus) async {
 guard !isSavingAttendance, status != .unmarked, status != record.status else { return }
 isSavingAttendance = true
 error = nil
 attendanceMessage = nil
 defer { isSavingAttendance = false }
 do {
 let updated = try await attendance.update(record, status: status)
 if let index = history.firstIndex(where: { $0.id == updated.id }) { history[index] = updated }
 attendanceMessage = "Attendance updated for \(record.attendanceDate)."
 NotificationCenter.default.post(name: .recordsChanged, object: nil)
 } catch is CancellationError {} catch { self.error = error.localizedDescription }
 }
 func delete() async -> Bool { guard let student else { return false }; do { try await students.delete(student.id); NotificationCenter.default.post(name: .recordsChanged, object: nil); return true } catch { self.error = error.localizedDescription; return false } }
}

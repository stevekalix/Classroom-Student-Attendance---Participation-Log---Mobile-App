import Foundation
import Combine
@MainActor final class AttendanceViewModel: ObservableObject {
 @Published var date = Date()
 @Published var students: [Student] = []
 @Published var selections: [Int64: AttendanceStatus] = [:]
 @Published var isLoading = false
 @Published var isSaving = false
 @Published var error: String?
 @Published var success: String?
 private var original: [Int64: AttendanceStatus] = [:]
 private var generation = 0
 private let roster: any StudentServiceProtocol
 private let attendance: any AttendanceServiceProtocol
 init(roster: (any StudentServiceProtocol)? = nil, attendance: (any AttendanceServiceProtocol)? = nil) { self.roster = roster ?? StudentService(); self.attendance = attendance ?? AttendanceService() }
 var hasChanges: Bool { selections != original }
 func load(studentId: Int64?) async {
 generation += 1; let requestGeneration = generation; let selectedDate = date
 isLoading = true; error = nil; success = nil
 defer { if generation == requestGeneration { isLoading = false } }
 do {
 var all: [Student] = []
 if let studentId { all = [try await roster.get(studentId)] }
 else {
 var page = 0; var more = true
 while more { let batch = try await roster.list(search: "", filter: StudentFilter(), page: page, size: 100, date: selectedDate); all += batch.content; page += 1; more = page < batch.totalPages; try Task.checkCancellation() }
 }
 let records = try await attendance.daily(selectedDate)
 try Task.checkCancellation(); guard generation == requestGeneration else { return }
 students = all.filter { $0.isActive && $0.enrollmentDate <= DateHelper.string(selectedDate) }
 let ids = Set(students.map(\.id))
 selections = Dictionary(uniqueKeysWithValues: records.filter { ids.contains($0.studentId) }.map { ($0.studentId, $0.status) }); original = selections
 } catch is CancellationError {} catch { if generation == requestGeneration { self.error = error.localizedDescription; students = []; selections = [:]; original = [:] } }
 }
 func markAll() { for student in students { selections[student.id] = .present } }
 func save() async {
 guard !isSaving && !isLoading else { return }
 let changed = selections.filter { original[$0.key] != $0.value && $0.value != .unmarked }
 guard !changed.isEmpty else { success = "No changes to save."; return }
 guard changed.count <= 500 else { error = "Save up to 500 changed students at a time."; return }
 isSaving = true; error = nil; success = nil; defer { isSaving = false }
 do { _ = try await attendance.save(changed.map { AttendanceRequest(studentId: $0.key, attendanceDate: DateHelper.string(date), status: $0.value) }); original = selections; success = "Attendance saved."; NotificationCenter.default.post(name: .recordsChanged, object: nil) }
 catch { self.error = error.localizedDescription }
 }
 func count(_ status: AttendanceStatus) -> Int { status == .unmarked ? students.count - selections.count : selections.values.filter { $0 == status }.count }
}

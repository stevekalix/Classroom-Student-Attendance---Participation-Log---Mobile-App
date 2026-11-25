import SwiftUI
struct StudentDetailView: View {
 let studentId: Int64
 @StateObject private var vm = StudentDetailViewModel()
 @Environment(\.dismiss) private var dismiss
 @State private var editing = false, deleting = false
 var body: some View { List {
 if let error = vm.error { ErrorView(message: error) { Task { await vm.load(studentId) } } }
 if vm.isLoading { LoadingView() }
 if let student = vm.student {
 Section { StudentRowView(student: student); LabeledContent("Enrolled", value: student.enrollmentDate); if let notes = student.academicNotes, !notes.isEmpty { Text(notes) }; if !student.isActive { Label("Archived student", systemImage: "archivebox") } }
 if let summary = vm.summary { Section("Attendance") { LabeledContent("Attendance rate", value: String(format: "%.1f%%", summary.attendancePercentage)); LabeledContent("Marked days", value: String(summary.totalDays)); LabeledContent("Present", value: String(summary.presentDays)); LabeledContent("Absent", value: String(summary.absentDays)); LabeledContent("Late", value: String(summary.lateDays)) } }
 Section("Classroom records") {
 NavigationLink("Attendance history") { AttendanceHistoryView(vm: vm, studentId: studentId) }
 if student.isActive { NavigationLink("Mark attendance") { AttendanceView(studentId: student.id) } }
 NavigationLink("Progress & participation notes") { NotesListView(studentId: student.id) }
 }
 if student.isActive { Button("Delete student", role: .destructive) { deleting = true } }
 }
 }.navigationTitle(vm.student?.fullName ?? "Student").navigationBarTitleDisplayMode(.inline)
 .task { await vm.load(studentId) }.refreshable { await vm.load(studentId) }
 .onReceive(NotificationCenter.default.publisher(for: .recordsChanged)) { _ in Task { await vm.load(studentId) } }
 .toolbar { if vm.student != nil { Button("Edit") { editing = true } } }
 .sheet(isPresented: $editing) { if let student = vm.student { NavigationStack { EditStudentView(student: student) } } }
 .alert("Delete student?", isPresented: $deleting) { Button("Cancel", role: .cancel) {}; Button("Delete", role: .destructive) { Task { if await vm.delete() { dismiss() } } } } message: { Text("The student will be archived. Attendance and notes are retained.") }
 }
}

import SwiftUI
struct AttendanceView: View {
 var studentId: Int64? = nil
 @StateObject private var vm = AttendanceViewModel()
 @State private var pendingDate: Date?
 var body: some View { List {
 Section { DatePicker("Date", selection: Binding(get: { vm.date }, set: { if vm.hasChanges { pendingDate = $0 } else { vm.date = $0 } }), displayedComponents: .date).disabled(vm.isSaving)
 HStack { ForEach(AttendanceStatus.allCases) { status in VStack { Text("\(vm.count(status))").font(.headline); Text(status.title).font(.caption2) }.frame(maxWidth: .infinity) } }.accessibilityElement(children: .combine)
 }
 if let error = vm.error { ErrorView(message: error) { Task { await vm.load(studentId: studentId) } } }
 if let success = vm.success { Label(success, systemImage: "checkmark.circle.fill").foregroundStyle(.green) }
 if vm.isLoading { LoadingView() }
 ForEach(vm.students) { student in AttendanceRowView(student: student, status: Binding(get: { vm.selections[student.id] ?? .unmarked }, set: { vm.selections[student.id] = $0 })).disabled(vm.isLoading || vm.isSaving) }
 if !vm.isLoading && vm.students.isEmpty && vm.error == nil { EmptyStateView(title: "No enrolled students", message: "Add students or select a date after enrollment.") }
 if !vm.students.isEmpty { Section { Button("Mark all present") { vm.markAll() }.disabled(vm.isLoading || vm.isSaving); PrimaryButton(title: "Save attendance", loading: vm.isSaving) { Task { await vm.save() } }.disabled(vm.isLoading || !vm.hasChanges) } }
 }.navigationTitle("Attendance").task(id: vm.date) { await vm.load(studentId: studentId) }
 .onReceive(NotificationCenter.default.publisher(for: .recordsChanged)) { _ in if !vm.hasChanges && !vm.isSaving { Task { await vm.load(studentId: studentId) } } }
 .alert("Discard unsaved attendance?", isPresented: Binding(get: { pendingDate != nil }, set: { if !$0 { pendingDate = nil } })) { Button("Keep editing", role: .cancel) { pendingDate = nil }; Button("Discard", role: .destructive) { if let date = pendingDate { vm.date = date }; pendingDate = nil } }
 }
}

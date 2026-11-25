import SwiftUI
struct StudentFilterView: View {
 @Binding var filter: StudentFilter
 @Environment(\.dismiss) private var dismiss
 var body: some View { Form {
 TextField("Class name (exact)", text: $filter.className)
 TextField("Subject group (exact)", text: $filter.subjectGroup)
 Picker("Attendance", selection: $filter.status) { Text("All").tag(nil as AttendanceStatus?); ForEach(AttendanceStatus.allCases) { Text($0.title).tag(Optional($0)) } }
 Toggle("Active students", isOn: $filter.active)
 Picker("Sort", selection: $filter.sort) { Text("Name").tag("fullName"); Text("Roll ID").tag("rollId"); Text("Enrollment date").tag("enrollmentDate") }
 Button("Reset filters") { filter = StudentFilter() }
 }.navigationTitle("Filters").toolbar { Button("Done") { dismiss() } } }
}

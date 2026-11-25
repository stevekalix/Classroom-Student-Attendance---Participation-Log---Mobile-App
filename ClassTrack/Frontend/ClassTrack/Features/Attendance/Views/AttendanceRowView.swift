import SwiftUI
struct AttendanceRowView: View {
 let student: Student
 @Binding var status: AttendanceStatus
 var body: some View { VStack(alignment: .leading, spacing: 10) { Text(student.fullName).font(.headline); Text(student.rollId).font(.caption).foregroundStyle(.secondary); Picker("Attendance for \(student.fullName)", selection: $status) { if status == .unmarked { Text("Unmarked").tag(AttendanceStatus.unmarked) }; ForEach([AttendanceStatus.present, .absent, .late]) { Label($0.title, systemImage: $0.symbol).tag($0) } }.pickerStyle(.menu) }.padding(.vertical, 4) }
}

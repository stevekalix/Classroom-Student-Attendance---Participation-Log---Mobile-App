import SwiftUI
struct StudentRowView: View { let student: Student
 var body: some View { HStack(alignment: .top, spacing: 14) {
 Text(student.initials).font(.headline).foregroundStyle(AppColors.primary).frame(width: 46, height: 46).background(AppColors.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 14)).accessibilityHidden(true)
 VStack(alignment: .leading, spacing: 5) { Text(student.fullName).font(AppTypography.headline); Text("\(student.rollId) · \(student.className)").font(.subheadline).foregroundStyle(.secondary); Text(student.subjectGroup).font(.caption).foregroundStyle(.secondary); StatusBadge(status: student.attendanceStatus) }
 }.padding(.vertical, 6).accessibilityElement(children: .combine) }
}

import Foundation
struct StudentForm: Codable {
 var fullName = "", rollId = "", className = "", subjectGroup = "Computer Science"
 var enrollmentDate = DateHelper.string(Date())
 var academicNotes = ""
 init() {}
 init(student: Student) { fullName = student.fullName; rollId = student.rollId; className = student.className; subjectGroup = student.subjectGroup; enrollmentDate = student.enrollmentDate; academicNotes = student.academicNotes ?? "" }
 var validationError: String? {
 if [fullName, rollId, className, subjectGroup].contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { return "Complete all required fields." }
 if fullName.count > 150 || rollId.count > 50 || className.count > 100 || subjectGroup.count > 100 || academicNotes.count > 10000 { return "One or more fields exceeds the permitted length." }
 return nil
 }
}
struct StudentFilter: Equatable {
 var className = "", subjectGroup = "", status: AttendanceStatus?, active = true, sort = "fullName"
 func query(search: String, page: Int, size: Int = 20, date: Date = Date()) -> [URLQueryItem] {
 var items = [URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "size", value: String(size)), URLQueryItem(name: "date", value: DateHelper.string(date)), URLQueryItem(name: "sort", value: sort), URLQueryItem(name: "active", value: String(active))]
 for (key, value) in [("search", search), ("className", className), ("subjectGroup", subjectGroup), ("status", status?.rawValue ?? "")] where !value.isEmpty { items.append(URLQueryItem(name: key, value: value)) }
 return items
 }
}

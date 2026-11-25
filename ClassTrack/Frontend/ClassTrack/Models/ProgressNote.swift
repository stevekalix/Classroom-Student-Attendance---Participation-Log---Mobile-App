import Foundation
enum NoteCategory: String, Codable, CaseIterable, Identifiable {
 case academic = "ACADEMIC_PROGRESS", participation = "PARTICIPATION", behavior = "BEHAVIOR", general = "GENERAL"
 var id: String { rawValue }
 var title: String { rawValue.replacingOccurrences(of: "_", with: " ").capitalized }
}
struct ProgressNote: Codable, Identifiable {
 let id, studentId, teacherId: Int64
 let category: NoteCategory
 let content, createdAt, updatedAt: String
}

import Foundation
struct Student: Codable, Identifiable, Equatable {
 let id: Int64
 let fullName, rollId, className, subjectGroup, enrollmentDate: String
 let academicNotes: String?
 let isActive: Bool
 let attendanceStatus: AttendanceStatus
 var initials: String { fullName.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased() }
}
struct PageResponse<T: Decodable>: Decodable { let content: [T]; let number, totalPages: Int; let totalElements: Int64 }

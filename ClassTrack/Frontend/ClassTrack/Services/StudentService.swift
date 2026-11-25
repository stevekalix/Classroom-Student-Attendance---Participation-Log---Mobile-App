import Foundation
@MainActor protocol StudentServiceProtocol {
 func list(search: String, filter: StudentFilter, page: Int, size: Int, date: Date) async throws -> PageResponse<Student>
 func get(_ id: Int64) async throws -> Student
 func save(_ form: StudentForm, id: Int64?) async throws -> Student
 func delete(_ id: Int64) async throws
}
@MainActor final class StudentService: StudentServiceProtocol {
 private let api: any APIClientProtocol
 init(api: (any APIClientProtocol)? = nil) { self.api = api ?? APIClient.shared }
 func list(search: String = "", filter: StudentFilter = StudentFilter(), page: Int = 0, size: Int = 20, date: Date = Date()) async throws -> PageResponse<Student> { try await api.request("students", method: .get, query: filter.query(search: search, page: page, size: size, date: date), body: nil) }
 func get(_ id: Int64) async throws -> Student { try await api.request("students/\(id)", method: .get, query: [], body: nil) }
 func save(_ form: StudentForm, id: Int64?) async throws -> Student { try await api.request(id.map { "students/\($0)" } ?? "students", method: id == nil ? .post : .patch, query: [], body: JSONEncoder().encode(form)) }
 func delete(_ id: Int64) async throws { let _: EmptyResponse = try await api.request("students/\(id)", method: .delete, query: [], body: nil) }
}

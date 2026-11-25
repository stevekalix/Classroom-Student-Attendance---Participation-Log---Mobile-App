import Foundation
@MainActor protocol NoteServiceProtocol { func list(studentId: Int64) async throws -> [ProgressNote]; func save(studentId: Int64, id: Int64?, category: NoteCategory, content: String) async throws -> ProgressNote; func delete(_ id: Int64) async throws }
@MainActor final class NoteService: NoteServiceProtocol {
 private let api: any APIClientProtocol
 init(api: (any APIClientProtocol)? = nil) { self.api = api ?? APIClient.shared }
 func list(studentId: Int64) async throws -> [ProgressNote] { try await api.request("students/\(studentId)/notes", method: .get, query: [], body: nil) }
 func save(studentId: Int64, id: Int64?, category: NoteCategory, content: String) async throws -> ProgressNote { try await api.request(id.map { "notes/\($0)" } ?? "students/\(studentId)/notes", method: id == nil ? .post : .patch, query: [], body: JSONEncoder().encode(NoteRequest(category: category, content: content))) }
 func delete(_ id: Int64) async throws { let _: EmptyResponse = try await api.request("notes/\(id)", method: .delete, query: [], body: nil) }
}

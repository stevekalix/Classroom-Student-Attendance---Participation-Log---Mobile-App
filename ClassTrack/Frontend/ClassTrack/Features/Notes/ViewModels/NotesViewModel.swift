import Foundation
import Combine
@MainActor final class NotesViewModel: ObservableObject {
 @Published var notes: [ProgressNote] = []
 @Published var isLoading = false
 @Published var isSaving = false
 @Published var error: String?
 private let service: any NoteServiceProtocol
 init(service: (any NoteServiceProtocol)? = nil) { self.service = service ?? NoteService() }
 func load(studentId: Int64) async {
 guard !isLoading else { return }; isLoading = true; error = nil; defer { isLoading = false }
 do { notes = try await service.list(studentId: studentId) } catch is CancellationError {} catch { self.error = error.localizedDescription }
 }
 func save(studentId: Int64, noteId: Int64?, category: NoteCategory, content: String) async -> Bool {
 guard !isSaving else { return false }
 guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, content.count <= 10000 else { error = "Enter a note between 1 and 10,000 characters."; return false }
 isSaving = true; error = nil; defer { isSaving = false }
 do { _ = try await service.save(studentId: studentId, id: noteId, category: category, content: content); NotificationCenter.default.post(name: .recordsChanged, object: nil); await load(studentId: studentId); return true } catch { self.error = error.localizedDescription; return false }
 }
 func delete(_ note: ProgressNote) async { do { try await service.delete(note.id); notes.removeAll { $0.id == note.id }; NotificationCenter.default.post(name: .recordsChanged, object: nil) } catch { self.error = error.localizedDescription } }
}

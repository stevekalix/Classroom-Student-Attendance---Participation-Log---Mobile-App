import Foundation
import Combine
@MainActor final class StudentListViewModel: ObservableObject {
 @Published var students: [Student] = []
 @Published var search = ""
 @Published var filter = StudentFilter()
 @Published var isLoading = false
 @Published var error: String?
 @Published var canLoadMore = false
 private var page = 0
 private var generation = 0
 private let service: any StudentServiceProtocol
 init(service: (any StudentServiceProtocol)? = nil) { self.service = service ?? StudentService() }
 func load(reset: Bool = true) async {
 if !reset && isLoading { return }
 if reset { generation += 1; page = 0; canLoadMore = false }
 let requestGeneration = generation
 isLoading = true; error = nil
 defer { if generation == requestGeneration { isLoading = false } }
 do {
 let result = try await service.list(search: search, filter: filter, page: page, size: 20, date: Date())
 try Task.checkCancellation(); guard generation == requestGeneration else { return }
 students = reset ? result.content : students + result.content
 page = result.number + 1; canLoadMore = page < result.totalPages
 } catch is CancellationError {} catch { if generation == requestGeneration { self.error = error.localizedDescription } }
 }
 func delete(_ student: Student) async { do { try await service.delete(student.id); NotificationCenter.default.post(name: .recordsChanged, object: nil); await load() } catch { self.error = error.localizedDescription } }
}

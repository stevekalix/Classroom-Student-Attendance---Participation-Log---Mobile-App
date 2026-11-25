import Foundation
import Combine
@MainActor class AddStudentViewModel: ObservableObject {
 @Published var form: StudentForm
 @Published var isLoading = false
 @Published var error: String?
 let id: Int64?
 private let service: any StudentServiceProtocol
 init(student: Student? = nil, service: (any StudentServiceProtocol)? = nil) { form = student.map(StudentForm.init) ?? StudentForm(); id = student?.id; self.service = service ?? StudentService() }
 func save() async -> Bool {
 guard !isLoading else { return false }
 if let validation = form.validationError { error = validation; return false }
 isLoading = true; error = nil; defer { isLoading = false }
 do { _ = try await service.save(form, id: id); NotificationCenter.default.post(name: .recordsChanged, object: nil); return true }
 catch { self.error = error.localizedDescription; return false }
 }
}

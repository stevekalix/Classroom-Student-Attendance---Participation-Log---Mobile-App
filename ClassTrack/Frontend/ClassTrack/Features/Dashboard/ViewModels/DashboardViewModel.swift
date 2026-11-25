import Foundation
import Combine
@MainActor final class DashboardViewModel: ObservableObject {
 @Published var summary: DashboardSummary?
 @Published var isLoading = false
 @Published var error: String?
 private let service: any DashboardServiceProtocol
 private var reloadPending = false
 init(service: (any DashboardServiceProtocol)? = nil) { self.service = service ?? DashboardService() }
 var slices: [AttendanceSlice] { guard let s = summary else { return [] }; return [AttendanceSlice(status: .present, count: s.presentCount), AttendanceSlice(status: .absent, count: s.absentCount), AttendanceSlice(status: .late, count: s.lateCount), AttendanceSlice(status: .unmarked, count: s.unmarkedCount)] }
 func load() async {
 if isLoading { reloadPending = true; return }; isLoading = true
 repeat {
 reloadPending = false; error = nil
 do { summary = try await service.summary() } catch is CancellationError {} catch { self.error = error.localizedDescription }
 } while reloadPending && !Task.isCancelled
 isLoading = false
 }
}

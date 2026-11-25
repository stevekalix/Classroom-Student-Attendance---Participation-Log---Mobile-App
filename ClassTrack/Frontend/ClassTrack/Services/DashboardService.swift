import Foundation
@MainActor protocol DashboardServiceProtocol { func summary() async throws -> DashboardSummary }
@MainActor final class DashboardService: DashboardServiceProtocol {
 private let api: any APIClientProtocol
 init(api: (any APIClientProtocol)? = nil) { self.api = api ?? APIClient.shared }
 func summary() async throws -> DashboardSummary { try await api.request("dashboard", method: .get, query: [URLQueryItem(name: "date", value: DateHelper.string(Date()))], body: nil) }
}

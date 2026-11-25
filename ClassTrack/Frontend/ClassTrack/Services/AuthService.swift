import Foundation
@MainActor protocol AuthServiceProtocol { func login(email: String, password: String) async throws -> AuthResponse; func register(name: String, email: String, password: String) async throws -> AuthResponse; func me() async throws -> Teacher }
@MainActor final class AuthService: AuthServiceProtocol {
 private let api: any APIClientProtocol
 init(api: (any APIClientProtocol)? = nil) { self.api = api ?? APIClient.shared }
 func login(email: String, password: String) async throws -> AuthResponse { try await api.request(APIEndpoint.login, method: .post, query: [], body: JSONEncoder().encode(LoginRequest(email: email, password: password))) }
 func register(name: String, email: String, password: String) async throws -> AuthResponse { try await api.request(APIEndpoint.register, method: .post, query: [], body: JSONEncoder().encode(RegisterRequest(fullName: name, email: email, password: password))) }
 func me() async throws -> Teacher { try await api.request(APIEndpoint.me, method: .get, query: [], body: nil) }
}

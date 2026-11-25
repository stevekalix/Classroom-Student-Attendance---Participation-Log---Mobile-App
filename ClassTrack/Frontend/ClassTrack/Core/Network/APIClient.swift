import Foundation
@MainActor
protocol APIClientProtocol: AnyObject {
 func request<T: Decodable>(_ path: String, method: HTTPMethod, query: [URLQueryItem], body: Data?) async throws -> T
}
@MainActor
final class APIClient: APIClientProtocol {
 static let shared = APIClient()
 var token: String?
 var onUnauthorized: (() -> Void)?
 private let session: URLSession
 private let baseURL: URL
 init(session: URLSession = .shared, baseURL: URL = APIConfiguration.baseURL) { self.session = session; self.baseURL = baseURL }
 func request<T: Decodable>(_ path: String, method: HTTPMethod = .get, query: [URLQueryItem] = [], body: Data? = nil) async throws -> T {
 guard var parts = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else { throw APIError.invalidResponse }
 parts.queryItems = query.isEmpty ? nil : query
 guard let url = parts.url else { throw APIError.invalidResponse }
 var request = URLRequest(url: url); request.httpMethod = method.rawValue; request.httpBody = body; request.timeoutInterval = 30
 request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
 let data: Data; let response: URLResponse
 do { (data, response) = try await session.data(for: request) }
 catch is CancellationError { throw CancellationError() }
 catch let error as URLError where error.code == .cancelled { throw CancellationError() }
 catch { throw APIError.network(error.localizedDescription) }
 try Task.checkCancellation()
 guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
 if http.statusCode == 401 {
 if path == APIEndpoint.login || path == APIEndpoint.register {
 let envelope = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data)
 throw APIError.server(401, envelope?.message ?? "Invalid email or password.")
 }
 onUnauthorized?()
 throw APIError.unauthorized
 }
 guard (200..<300).contains(http.statusCode) else {
 let envelope = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data)
 throw APIError.server(http.statusCode, envelope?.message ?? "Request failed (\(http.statusCode)).")
 }
 if http.statusCode == 204, let empty = EmptyResponse() as? T { return empty }
 do {
 let envelope = try JSONDecoder().decode(APIResponse<T>.self, from: data)
 guard envelope.success, let value = envelope.data else { throw APIError.invalidResponse }
 return value
 } catch let error as APIError { throw error } catch { throw APIError.decoding }
 }
}

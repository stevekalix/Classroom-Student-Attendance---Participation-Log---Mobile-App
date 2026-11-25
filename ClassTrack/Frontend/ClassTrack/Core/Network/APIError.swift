import Foundation
enum APIError: LocalizedError {
 case invalidResponse, decoding, unauthorized, server(Int, String), network(String)
 var errorDescription: String? {
 switch self {
 case .invalidResponse: return "The server returned an invalid response."
 case .decoding: return "The response could not be read. Please check the server version."
 case .unauthorized: return "Your session expired. Please sign in again."
 case .server(_, let message), .network(let message): return message
 }
 }
}

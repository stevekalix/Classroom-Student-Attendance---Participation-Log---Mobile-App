import Foundation
struct APIResponse<T: Decodable>: Decodable { let success: Bool; let message: String?; let data: T?; let code: String? }
struct EmptyResponse: Codable {}

import Foundation
enum APIConfiguration {
 static var baseURL: URL {
 let value = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String ?? "http://127.0.0.1:8080/api/v1"
 guard let url = URL(string: value), let scheme = url.scheme, ["http", "https"].contains(scheme), url.host != nil else { preconditionFailure("Set a valid API_BASE_URL in the build configuration") }
 #if !DEBUG
 precondition(scheme == "https", "Release builds require HTTPS")
 #endif
 return url
 }
}

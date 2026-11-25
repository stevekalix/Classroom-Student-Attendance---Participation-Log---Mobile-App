import Foundation
struct LoginRequest: Encodable { let email, password: String }
struct RegisterRequest: Encodable { let fullName, email, password: String }
struct AuthResponse: Decodable { let token, tokenType: String; let expiresIn: Int; let teacher: Teacher }

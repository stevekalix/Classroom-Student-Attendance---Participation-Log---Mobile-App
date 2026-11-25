import Foundation
enum Validators {
 static func email(_ value: String) -> Bool { value.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil && value.count <= 254 }
 static func password(_ value: String) -> Bool { value.count >= 10 && value.utf8.count <= 72 && value.range(of: "[A-Z]", options: .regularExpression) != nil && value.range(of: "[a-z]", options: .regularExpression) != nil && value.range(of: "[0-9]", options: .regularExpression) != nil }
}

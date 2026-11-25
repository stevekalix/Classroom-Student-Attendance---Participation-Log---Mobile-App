import Foundation
import Security
import LocalAuthentication
struct KeychainManager {
 private let service = "com.classtrack.session"
 private var query: [String: Any] { [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: "jwt"] }
 func save(_ token: String, biometric: Bool) throws {
 var item = query
 item[kSecValueData as String] = Data(token.utf8)
 if biometric {
 var error: Unmanaged<CFError>?
 guard let control = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .biometryCurrentSet, &error) else { throw APIError.network("A device passcode and biometrics are required.") }
 item[kSecAttrAccessControl as String] = control
 } else { item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly }
 try delete()
 let status = SecItemAdd(item as CFDictionary, nil)
 guard status == errSecSuccess else { throw failure(status) }
 }
 func read(context: LAContext? = nil) throws -> String? {
 var item = query; item[kSecReturnData as String] = true; item[kSecMatchLimit as String] = kSecMatchLimitOne
 if let context { item[kSecUseAuthenticationContext as String] = context }
 var result: CFTypeRef?
 let status = SecItemCopyMatching(item as CFDictionary, &result)
 if status == errSecItemNotFound { return nil }
 guard status == errSecSuccess, let data = result as? Data, let value = String(data: data, encoding: .utf8) else { throw failure(status) }
 return value
 }
 func delete() throws { let status = SecItemDelete(query as CFDictionary); guard status == errSecSuccess || status == errSecItemNotFound else { throw failure(status) } }
 private func failure(_ status: OSStatus) -> APIError { .network(SecCopyErrorMessageString(status, nil) as String? ?? "Secure storage is unavailable.") }
}
